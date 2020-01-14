package ipfs

import (
	"bytes"
	"context"
	"fmt"
	"io/ioutil"
	"net"
	"net/http"
	"net/url"
	"strings"

	ipfs_api "github.com/ipfs/go-ipfs-api"
	ma "github.com/multiformats/go-multiaddr"
	manet "github.com/multiformats/go-multiaddr-net"
)

type Shell struct {
	client *http.Client
	url    string
	ishell *ipfs_api.Shell
}

func NewShell(maddr string) (*Shell, error) {
	var client *http.Client

	a, err := ma.NewMultiaddr(maddr)
	if err != nil {
		return nil, fmt.Errorf("unable to parse multiaddr: %s", err)
	}

	_, host, err := manet.DialArgs(a)
	if err != nil {
		return nil, err
	}

	ma.ForEach(a, func(c ma.Component) bool {
		switch c.Protocol().Code {
		case ma.P_IP4, ma.P_IP6:
			client = &http.Client{
				Transport: &http.Transport{
					Proxy:             http.ProxyFromEnvironment,
					DisableKeepAlives: true,
				},
			}
		case ma.P_UNIX:
			client = &http.Client{
				Transport: &http.Transport{
					Proxy:             http.ProxyFromEnvironment,
					DisableKeepAlives: true,
					DialContext: func(_ context.Context, _, _ string) (net.Conn, error) {
						return net.Dial("unix", c.Value())
					},
				},
			}

			host = "unix"
		default:
			return false
		}

		return true
	})

	if client == nil {
		return nil, fmt.Errorf("unable to create a shell, `%s` is not supported", maddr)
	}

	ishell := ipfs_api.NewShellWithClient(host, client)
	return &Shell{client, host, ishell}, nil
}

func (s *Shell) NewRequest(command string) *RequestBuilder {
	return &RequestBuilder{
		rb: s.ishell.Request(strings.TrimLeft(command, "/")),
	}
}

func (s *Shell) Request(uri string, body []byte) ([]byte, error) {
	u, err := url.Parse(uri)
	if err != nil {
		return nil, err
	}

	command := strings.TrimLeft(u.EscapedPath(), "/")
	ireq := ipfs_api.NewRequest(context.Background(), s.url, command)
	if len(body) > 0 {
		ireq.Body = bytes.NewReader(body)
	}

	for k, v := range u.Query() {
		ireq.Opts[k] = strings.Join(v, ",")
	}

	res, err := ireq.Send(s.client)
	if err != nil {
		return nil, err
	}

	defer res.Close()
	if res.Error != nil {
		return nil, res.Error
	}

	return ioutil.ReadAll(res.Output)
}

type RequestBuilder struct {
	rb *ipfs_api.RequestBuilder
}

func (req *RequestBuilder) Send() ([]byte, error) {
	res, err := req.rb.Send(context.Background())
	if err != nil {
		return nil, err
	}

	defer res.Close()
	if res.Error != nil {
		return nil, res.Error
	}

	return ioutil.ReadAll(res.Output)
}

func (req *RequestBuilder) Exec() error {
	return req.Exec()
}

func (req *RequestBuilder) Argument(arg string) {
	req.rb.Arguments(arg)
}

func (req *RequestBuilder) BoolOptions(key string, value bool) {
	req.rb.Option(key, value)
}

func (req *RequestBuilder) ByteOptions(key string, value []byte) {
	req.rb.Option(key, value)
}

func (req *RequestBuilder) StringOptions(key string, value string) {
	req.rb.Option(key, value)
}

func (req *RequestBuilder) BodyString(body string) {
	req.rb.BodyString(body)
}

func (req *RequestBuilder) BodyBytes(body []byte) {
	req.rb.BodyBytes(body)
}

func (req *RequestBuilder) Header(name, value string) {
	req.rb.Header(name, value)
}

// Helpers

// New unix socket domain shell
func NewUDSShell(sockpath string) (*Shell, error) {
	return NewShell("/unix/" + sockpath)
}

func NewTCPShell(port string) (*Shell, error) {
	return NewShell("/ip4/127.0.0.1/tcp/" + port)
}
