package core

// Config is used in NewNode.
type NodeConfig struct {
	bleDriver        ProximityDriver
	netDriver        NativeNetDriver
	mdnsLockerDriver NativeMDNSLockerDriver
}

func NewNodeConfig() *NodeConfig {
	return &NodeConfig{
	}
}

func (c *NodeConfig) SetBleDriver(driver ProximityDriver)         { c.bleDriver = driver }
func (c *NodeConfig) SetNetDriver(driver NativeNetDriver)         { c.netDriver = driver }
func (c *NodeConfig) SetMDNSLocker(driver NativeMDNSLockerDriver) { c.mdnsLockerDriver = driver }
