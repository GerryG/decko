
package main

import (
	//"ipld https://github.com/ipld/go-ipld"
	"encoding/json"
	"C"
	"fmt"
)

//export ipldpublish
func ipldpublish(jdata *C.char) (hash *C.char) {
	var gdata = C.GoString(jdata)
	var m map[string]string
	if gdata == "" {
		fmt.Printf("No jdata\n")
	}
	fmt.Printf("publish to ipfs L %d\n", len(gdata))
	//fmt.Printf("publish to ipfs %#v\n", jdata)

	err := json.Unmarshal([]byte(gdata), &m)
	if err != nil { return C.CString("") }
	//hash = ipld.Node(...)
	fmt.Printf("publish to ipfs: %#v\n", m)
	return hash
}

func main() {}
