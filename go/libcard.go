
package main

import (
	//"ipld https://github.com/ipld/go-ipld"
	"encoding/json"
	"C"
	"fmt"
)

func go_publish(jdata string) (hash string) {
	var m map[string]string
	err := json.Unmarshal([]byte(jdata), &m)
	if err != nil { return "" }
	//hash = ipld.Node(...)
	fmt.Printf("publish to ipfs: %#v\n", m)
	return hash
}

func main() {}
