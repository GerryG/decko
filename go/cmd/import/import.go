
package main

import (
	"strconv"
	"math/big"
	"fmt"
	"time"
	"github.com/jinzhu/gorm"
	_ "github.com/jinzhu/gorm/dialects/mysql"
)

type Card struct {
	//gorm.Model Can't have DeletedAt
	ID                uint     `gorm:"primary_key"`
	Name              string   `gorm:"unique_index"`
	Key               string   `gorm:"unique_index"`
	Codename          string
	Left              *Card
	LeftID            uint
	Right             *Card
	RightID           uint
	//CurrentRevision Revision // if we need to read revs (Act or Action?)
	CurrentRevisionID uint
	CreatedAt         time.Time
	UpdatedAt         time.Time
	Creator           *Card
	CreatorID         uint
	Updater           *Card
	UpdaterID         uint
	ReadRuleClass     string
	ReadRuleID        uint
	ReferencesExpired uint
	Trash             bool
	Type              *Card
	TypeID            uint
	Content string // text (large)
	nodeRef string
}

var cards []Card
var byid  map[uint]uint = map[uint]uint{}
var children [](map[string]uint)

func id2card(id uint) *Card { return &cards[byid[id]] }
func id2children(id uint) map[string]uint { return children[byid[id]]}

func main() {
	dbuser := "root"
	dbpw := "decko123"
	dbname := "mydev_development"
	cstring := dbuser+":"+dbpw+"@/"+dbname+"?charset=utf8&parseTime=True&loc=Local"
	db, err := gorm.Open("mysql", cstring)
	if err != nil {
		panic(fmt.Sprintf("Error opening db[%s, %s] %v", dbuser, dbname, err))
	}
	defer db.Close()
	errs := db.GetErrors()
	if len(errs) > 0 {
		panic(fmt.Sprintf("Error reading from db: %v", errs))
	}
	//fmt.Printf("DB %s, %s\n", dbuser, dbname)
	db.LogMode(true)

	db.Find(&cards)
        children = make([]map[string]uint, len(cards))
	errs = db.GetErrors()
	if len(errs) > 0 {
		panic(fmt.Sprintf("Error reading from db: %v", errs))
	}

	// pass 1: create card_id to array index map
	for i, c := range cards {
		byid[c.ID] = uint(i)
	}
	// pass 2: create children maps
	//	children[idx] => map[tagKey] = idx
	for i, c := range cards {
		//fmt.Printf("Card[%d, %d] %v, %v %s\n", i, c.ID, c.LeftID, c.RightID, c.Name)
		if c.LeftID != 0 {
			lc := id2card(c.LeftID)
			if lc.ID != c.LeftID { panic(fmt.Sprintf("!= %d %d", lc.ID, c.LeftID)) }
			lidx := byid[lc.ID]
			lchrn := id2children(lc.ID)
			if lchrn == nil {
				lchrn = map[string]uint{}
				children[lidx] = lchrn
			}
			//fmt.Printf("Left: %s %d lenC:%d\n", lc.Name, lc.ID, len(lchrn))
			lchrn[id2card(c.RightID).Key] = uint(i)
			//fmt.Printf("Lft %d: %#v\n", c.LeftID, id2card(c.RightID))
		}
	}

	// debugging, dump maps
	//fmt.Printf("\nPhase change: %d, %d\n\n", len(byid), len(children))
	/*for id, idx := range byid {
		c1 := id2card(id)
		c2 := &cards[idx]
		fmt.Printf(" [%d]%s => [%d]%s   ", id, c1.Name, idx, c2.Name)
	}*/
	/*fmt.Printf("\n\n")
	for idx, m := range children {
		c2 := &cards[idx]
		fmt.Printf(" [%d]%s =>   ", idx, c2.Name)
		for k, v := range m {
			c2 := &cards[v]
			fmt.Printf(" %s => [%d]%s   ", k, idx, c2.Name)
		}
		fmt.Printf("\n")
	}*/
	//fmt.Printf("\n\n")
	// pass 3: compute the hashes
	for _, c := range cards {
		//fmt.Printf("ccH1:key:%s\n", c.Key)
		computeHash("", &c)
	}
}

func computeHash(idt string, c *Card) (thash *big.Int) {
	idx := byid[c.ID]
	if c.nodeRef != "" && c.nodeRef != "started" {
		//fmt.Printf("%ssk[%s]%s\n", idt, c.Key, c.nodeRef)
		return
	}
	c.nodeRef = "started"
	//fmt.Printf("%scH[%s]i:%d, %s\n", idt, c.nodeRef, idx, c.Name)
	tval := ""
	if c.ID == c.TypeID {
		//fmt.Printf("%scH2:%d (self-type(Cardtype type))\n", idt, c.ID)
		tval = `"Cardtype"`
	} else if byid[c.TypeID] != 0 {
		t := id2card(c.TypeID)
		if t.nodeRef == "" {
			//fmt.Printf("%sccH2type: %d\n", idt, t.ID)
			computeHash(idt+" ", t)
		}
		tval = `{"/": "/ipfs/`+t.nodeRef+`"}`
		//tval = `{"/": "/ipfs/`+"thehashfortype:"+strconv.Itoa(int(t.ID))+`"}`
	} else { fmt.Printf("Warn type not in byid %d\n", c.TypeID); return nil }

	for _, chidx := range id2children(c.ID) {
		chld := &cards[chidx]
		//fmt.Printf("%sccH3ch %s (%d) %s\n", idt, k, chld.ID, chld.Key)
		computeHash(idt+" ", chld)
	}

	/*fmt.Printf("%sCh< ", idt)
	for k, chidx := range id2children(c.ID) {
		fmt.Printf("%s => [%d]%s ", k, chidx, cards[idx].Name)
	}
	fmt.Printf(">\n")*/
	jsonstring := `{"Name": "`+c.Name+`", "Key": "`+c.Key+`", "Type": `+tval+`", `
	if c.Content != "" { // inline content, big and file content is a content ref
		jsonstring += `"Content": "`+c.Content+`", `
	}
	for k, chidx := range id2children(c.ID) {
		chld := &cards[chidx]
		jsonstring += `"`+k+`": {"/": "`+chld.nodeRef+`"}, `
	}
	jsonstring += `}`
	fmt.Printf("\n%sjson[%d] %s\n", idt, c.ID, jsonstring)
	// compute hash from json
	myhash := new(big.Int)
	c.nodeRef = "jhshdata:"+c.Key+":"+strconv.Itoa(int(c.ID)) //myhash.String()
	fmt.Printf("%sRet %d %s\n", idt, idx, c.Name)
	//fmt.Printf("Ret %d %s\n", c.ID, c.nodeRef)
	return myhash
}


