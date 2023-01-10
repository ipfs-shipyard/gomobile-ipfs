package core

import (
	"context"
	"errors"
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

	if res.Error != nil {
		return nil, errors.New(res.Error.Error())
	}
	return &ReadCloser{res.Output}, nil
}

func (req *RequestBuilder) SendToBytes() ([]byte, error) {
	res, err := req.rb.Send(context.Background())
	if err != nil {
		return nil, err
	}

	defer res.Close()
	if res.Error != nil {
		return nil, errors.New(res.Error.Error())
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

func (req *RequestBuilder) Body(body NativeReader) {
	req.rb.Body(&ReaderWrapper{body})
}

func (req *RequestBuilder) BodyString(body string) {
	req.rb.BodyString(body)
}

func (req *RequestBuilder) BodyBytes(body []byte) {
	// Need to copy body
	// https://github.com/golang/go/issues/33745
	var dest = make([]byte, len(body))
	copy(dest, body)
	req.rb.BodyBytes(dest)
}

func (req *RequestBuilder) FileBody(name string, body NativeReader) {
	fr := files.NewReaderFile(&ReaderWrapper{body})
	slf := files.NewSliceDirectory([]files.DirEntry{files.FileEntry(name, fr)})
	req.rb.Body(files.NewMultiFileReader(slf, false))
}

func (req *RequestBuilder) Header(name, value string) {
	req.rb.Header(name, value)
}

type NativeReader interface {
	// Read up to size bytes and return a new byte array, or nil for EOF.
	// Name this function differently to distinguish from io.Reader.
	NativeRead(size int) (b []byte, err error)
}

type ReaderWrapper struct {
	reader NativeReader
}

func (r *ReaderWrapper) Read(p []byte) (int, error) {
	b, err := r.reader.NativeRead(len(p))
	if err != nil {
		return 0, err
	}
	if b == nil {
		return 0, io.EOF
	}
	copy(p, b)

	return len(b), nil
}

type ReadCloser struct {
	readCloser io.ReadCloser
}

func (rc *ReadCloser) Close() error {
	return rc.readCloser.Close()
}

func (rc *ReadCloser) Read(p []byte) (n int, err error) {
	n, err = rc.readCloser.Read(p)
	if err == io.EOF && n > 0 {
		// Some bytes were read before the EOF. Return the bytes with no error
		// (to not throw an exception). The next call will return (0, io.EOF) .
		err = nil
	}
	return
}

// Helpers

// New unix socket domain shell
func NewUDSShell(sockpath string) *Shell {
	return NewShell("/unix/" + sockpath)
}

func NewTCPShell(port string) *Shell {
	return NewShell("/ip4/127.0.0.1/tcp/" + port)
}
