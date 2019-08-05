package mobile

import "fmt"

type Node interface {
	// Close ipfs node
	Close() error
}

type Repo interface {
	// Close ipfs node
	Close() error
}

func NewNode(r *Repo) (Node, error) {
	if !r.IsInitialized() {
		return fmt.Errorf("repo not initialized")
	}

	repo := r.Open()

}
