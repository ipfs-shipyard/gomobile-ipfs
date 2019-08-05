package host

import (
	"bytes"
	"encoding/json"
	"fmt"
)

type MobileConfig struct {
}

func FromMap(v map[string]interface{}) (*Config, error) {
	buf := new(bytes.Buffer)
	if err := json.NewEncoder(buf).Encode(v); err != nil {
		return nil, err
	}
	var conf MobileConfig
	if err := json.NewDecoder(buf).Decode(&conf); err != nil {
		return nil, fmt.Errorf("failure to decode config: %s", err)
	}
	return &conf, nil
}

func ToMap(conf *MobileConfig) (map[string]interface{}, error) {
	buf := new(bytes.Buffer)
	if err := json.NewEncoder(buf).Encode(conf); err != nil {
		return nil, err
	}
	var m map[string]interface{}
	if err := json.NewDecoder(buf).Decode(&m); err != nil {
		return nil, fmt.Errorf("failure to decode config: %s", err)
	}
	return m, nil
}
