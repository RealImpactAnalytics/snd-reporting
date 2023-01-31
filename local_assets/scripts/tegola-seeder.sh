#!/usr/bin/env bash

#########################################################
#
# This script leverages the Tegola CLI to compute the
# tileset for the map of the KPI explorer.
#
#########################################################

# Define geo bounding box query to filter out crazy points outside the country
# Use http://bboxfinder.com/ to play with parameters
read -r -d '' GEO_BASE_QUERY << EOM
    WITH highest_levels AS (
        SELECT max(level) AS maxlevel FROM metrics.dim_geo_places
    ),
    shapes AS (
        SELECT maxlevel AS lv, geo.shape AS geo_shape
        FROM  metrics.dim_geo_places AS geo
        JOIN highest_levels ON true WHERE geo.level = maxlevel AND geo.parent_id IS NULL
    ),
    country_shape AS (
        SELECT lv, ST_Union( geo_shape) AS country FROM shapes GROUP BY lv
    ),
    country_bbox AS (
        SELECT ST_SetSRID(ST_Expand(ST_Extent( country ), 0.04), 4326) AS bbox FROM country_shape
    )
EOM

# Extract docker compose project
tegola_container_name=$(docker ps --filter "label=com.docker.compose.service=tegola" --format='{{.Names}}')


function get_bounding_box {
    local data_broker_container=$(docker ps --filter "label=com.docker.compose.service=data-broker-service-db" --format="{{.Names}}")

    docker exec -i ${data_broker_container} psql -U postgres -d data_modules -t -c "$1"
}

function tegola_cache_seed {
    docker exec -d ${tegola_container_name} /opt/tegola --config /tegola_config.toml cache seed --overwrite --map $1 --min-zoom $2 --max-zoom $3 --bounds "$4"
}

function purge_cache {

    # Wipe cache the hard way instead
    local tegola_cache_container=$(docker ps --filter "label=com.docker.compose.service=tegola-redis-cache" --format="{{.Names}}")

    docker exec -i ${tegola_cache_container} rm -rf /backups/appendonly.aof
    docker restart ${tegola_cache_container} ${tegola_container_name}
}

function seed_geo_places {
    echo "===> Seeding geo places tiles"
    set -e

    GEO_QUERY="$GEO_BASE_QUERY SELECT concat_ws(',', ST_XMin(bbox), ST_YMin(bbox), ST_XMax(bbox), ST_YMax(bbox)) FROM country_bbox"

    local geo_bbbox=$(get_bounding_box "$GEO_QUERY")
    tegola_cache_seed snd_geo_places 1 16 "$geo_bbbox"
}

function seed_sites {
    echo "===> Seeding sites tiles"

    set +e
read -r -d '' SITES_QUERY << EOM
    ${GEO_BASE_QUERY},
    site_locations AS (
        SELECT 'site_box' AS box, location AS site_location FROM metrics.dim_sites
    ),
    sites_inside_counbtry as (
        SELECT * FROM site_locations JOIN country_bbox ON TRUE WHERE ST_WITHIN(site_location, bbox)
    ),
    sites_bbox AS (
        SELECT box, ST_Extent(site_location) AS bbox FROM sites_inside_counbtry GROUP BY box
    )
    SELECT concat_ws(',', ST_XMin(bbox), ST_YMin(bbox), ST_XMax(bbox), ST_YMax(bbox)) FROM sites_bbox
EOM

    local site_bbbox=$(get_bounding_box "$SITES_QUERY")
    tegola_cache_seed snd_sites_data 10 18 "$site_bbbox"
}

function seed_pos {
    echo "===> Seeding pos tiles"

    set +e
read -r -d '' POS_QUERY << EOM
    WITH pos AS (
        SELECT poi.external_id, pcf.location, poi.deleted , greatest(poi.snd_updated_by::date, poi.snd_updated_on::date)
        FROM dim.poi poi
        INNER JOIN dim.poi_computed_fields AS pcf ON pcf.poi_id = poi.id
        WHERE location IS NOT NULL AND NOT deleted
    ),
    locations AS (
        SELECT 'pos_box' AS box, location FROM pos
    ),
    pos_bbox AS (
        SELECT box, ST_Extent(location) AS bbox FROM locations GROUP BY box
    )
    SELECT concat_ws(',', ST_XMin(bbox), ST_YMin(bbox), ST_XMax(bbox), ST_YMax(bbox)) FROM pos_bbox
EOM
    set -e
    echo "========> Get tiles bounding box"
    local pos_bbbox=$(get_bounding_box "$POS_QUERY")
    echo "========> Seed tegola pos tiles in bounding box: $pos_bbbox"
    tegola_cache_seed snd_pos_data 16 18 "$pos_bbbox"
    echo "===> Seeding of pos tiles done"
}

# Expects that this differential seed runs daily
# It will take the new updated pos since yesterday
function seed_new_pos {

    echo "===> Seeding incremental pos tiles"

    set +e

    local YESTERDAY=$(date -d "yesterday" '+%Y-%m-%d')

read -r -d '' POS_QUERY_DIFF << EOM
    WITH pos AS (
        SELECT poi.external_id, pcf.location, poi.deleted , greatest(poi.snd_updated_by::date, poi.snd_updated_on::date)
        FROM dim.poi poi
        INNER JOIN dim.poi_computed_fields AS pcf ON pcf.poi_id = poi.id
        WHERE location IS NOT NULL AND NOT deleted AND greatest(poi.snd_updated_by::date, poi.snd_updated_on::date) > '$YESTERDAY'::date
    ),
    locations AS (
        SELECT 'pos_box' AS box, location FROM pos
    ),
    pos_bbox AS (
        SELECT box, ST_Extent(location) AS bbox FROM locations GROUP BY box
    )
    SELECT concat_ws(',', ST_XMin(bbox), ST_YMin(bbox), ST_XMax(bbox), ST_YMax(bbox)) FROM pos_bbox
EOM

    local pos_bbbox=$(get_bounding_box "$POS_QUERY_DIFF")
    tegola_cache_seed snd_pos_data 16 18 "$pos_bbbox"
}

######################################################################
# MAIN
######################################################################

layer="$1"

set -e
set -u

if [[ "$layer" == "pos" ]]; then
    seed_pos
elif [[ "$layer" == "new_pos" ]]; then
    seed_new_pos
elif [[ "$layer" == "geo" ]]; then
    seed_geo_places
elif [[ "$layer" == "sites" ]]; then
    seed_sites
elif [[ "$layer" == "all" ]]; then
    seed_geo_places
    seed_sites
    seed_pos
elif [[ "$layer" == "purge" ]]; then
    purge_cache
else
    echo "layer $layer not supported, please chose one of geo, pos or sites"
fi
