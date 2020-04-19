CREATE TABLE capacity.SCOMPerformance_raw
(
    `PartitionKey` date,
    `DateKey` datetime,
    `TimeSampled` datetime,
    `Path` String,
    `Serial` String,
    `ObjectName` String,
    `CounterName` String,
    `InstanceName` String,
    `CounterValue` Float32,
    `SnapshotTime` datetime,
    `InsertTime` datetime,
    `Multiplier` UInt8
)
ENGINE = MergeTree()
PARTITION BY PartitionKey
ORDER BY PartitionKey