package core

// Config is used in NewNode.
type NodeConfig struct {
	bleDriver ProximityDriver
}

func NewNodeConfig() *NodeConfig {
	return &NodeConfig{
	}
}

func (c *NodeConfig) SetBleDriver(driver ProximityDriver) { c.bleDriver = driver }
