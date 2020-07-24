package core

import (
	"context"
	"io"
	"io/ioutil"
	"strings"

	ipfs_api "github.com/ipfs/go-ipfs-api"
	files "github.com/ipfs/go-ipfs-files"
)

type Shell struct {
	ishell *ipfs_api.Shell
	url    string
}

func NewShell(url string) *Shell {
	return &Shell{
		ishell: ipfs_api.NewShell(url),
		url:    url,
	}
}

func (s *Shell) NewRequest(command string) *RequestBuilder {
	return &RequestBuilder{
		rb: s.ishell.Request(strings.TrimLeft(command, "/")),
	}
}

type RequestBuilder struct {
	rb *ipfs_api.RequestBuilder
}

func (req *RequestBuilder) Send() (*ReadCloser, error) {
	res, err := req.rb.Send(context.Background())
	if err != nil {
		return nil, err
	}

	return &ReadCloser{res.Output}, res.Error
}

func (req *RequestBuilder) SendToBytes() ([]byte, error) {
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

func (req *RequestBuilder) Argument(arg string) {
	req.rb.Arguments(arg)
}

func (req *RequestBuilder) BoolOptions(key string, value bool) {
	req.rb.Option(key, value)
}

func (req *RequestBuilder) BytesOptions(key string, value []byte) {
	req.rb.Option(key, value)
}

func (req *RequestBuilder) StringOptions(key string, value string) {
	req.rb.Option(key, value)
}

func (req *RequestBuilder) Body(body Reader) {
	req.rb.Body(body)
}

func (req *RequestBuilder) BodyString(body string) {
	req.rb.BodyString(body)
}

func (req *RequestBuilder) BodyBytes(body []byte) {
	req.rb.BodyBytes(body)
}

func (req *RequestBuilder) FileBody(name string, body Reader) {
	fr := files.NewReaderFile(body)
	slf := files.NewSliceDirectory([]files.DirEntry{files.FileEntry(name, fr)})
	req.rb.Body(files.NewMultiFileReader(slf, false))
}

func (req *RequestBuilder) Header(name, value string) {
	req.rb.Header(name, value)
}

type Reader interface {
	io.Reader
}

type ReadCloser struct {
	readCloser io.ReadCloser
}

func (rc *ReadCloser) Close() error {
	return rc.readCloser.Close()
}

func (rc *ReadCloser) Read(p []byte) (n int, err error) {
	return rc.readCloser.Read(p)
}

// Helpers

// New unix socket domain shell
func NewUDSShell(sockpath string) *Shell {
	return NewShell("/unix/" + sockpath)
}

func NewTCPShell(port string) *Shell {
	return NewShell("/ip4/127.0.0.1/tcp/" + port)
}
