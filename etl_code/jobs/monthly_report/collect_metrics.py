from mjolnir_python.pyspark_tools.spark_transformation import (
    DfOrConType,
    SparkTransformation,
)
from typing import NamedTuple

# class Input(NamedTuple):
#     airtime_pos_profile: DfOrConType
#     mfs_pos_profile: DfOrConType

# class Output(NamedTuple):
#     usage_analytics: DfOrConType


# class OraExport(SparkTransformation[Input, Output]):
class CollectMetrics(SparkTransformation[None, None]):
    # input_connectors = Input(
    #     airtime_pos_profile=pipeline_state_ds.AIRTIME_POS_PROFILE,
    #     mfs_pos_profile=pipeline_state_ds.MFS_POS_PROFILE,
    # )

    # output_connectors = Output(usage_analytics=pipeline_state_ds.USAGE_ANALYTICS_ORANGE_REPORT)

    def run(self, *args):
        # inputs = self.input_df()
        print(self.config)

        # self.write_df(Output(usage_analytics=normalize_colnames(Output_df),))


