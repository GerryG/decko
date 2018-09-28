
package main

import (
	"fmt"
	"time"
	"os"
	"io/ioutil"
	"encoding/json"
	"path"
	"path/filepath"
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
	Content string   `gorm:"column:db_content" sql:"type:text"` // text (large)
	nodeRef string
}

var cards []Card
var byid  map[uint]uint = map[uint]uint{}
var children [](map[string]uint)

func id2card(id uint) *Card { return &cards[byid[id]] }
func id2children(id uint) map[string]uint { return children[byid[id]]}

var dbuser string = "root"
var dbpw string = "decko123"
var dbname string = "mydev_development"
var outdir string = "/home/gerry/expdeck/"
var srcdir string = "/home/gerry/mysite/files"
var machineID uint = 18 // could find the type, but this is the only type in seeds with external files

func main() {
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
	fmt.Printf("Card: %#v\n", cards[1])
	fmt.Printf("Card: %#v\n", cards[2])
        children = make([]map[string]uint, len(cards))
	errs = db.GetErrors()
	if len(errs) > 0 {
		panic(fmt.Sprintf("Error reading from db: %v", errs))
	}

	// Create node diretories and card detail objects
	for _, c := range cards {
		outputNode(&c)
	}
}

func outputNode(c *Card) {
	nodepath := filepath.Join(outdir, c.Key)
	err := os.MkdirAll(nodepath, os.ModePerm)
	check(err)
	f, err := os.Create(filepath.Join(nodepath, "content.json"))
	check(err)
	defer f.Close()

	data, err := json.Marshal(c)
	check(err)
	n, err := f.Write(data)
	if n != len(data) {
		panic("Incomplete write")
	}

	if c.TypeID == machineID && c.Content != "" { // write the external file to node dir
		_, base := path.Split(c.Content)
		fmt.Printf("ext file %#v\n%s, %s\n", c, filepath.Join(srcdir, c.Content), base)
		dat, err := ioutil.ReadFile(filepath.Join(srcdir, c.Content))
		check(err)
		err = ioutil.WriteFile(filepath.Join(nodepath, base), dat, os.ModePerm)
		check(err)
	}
}

func check(e error) {
    if e != nil {
        //fmt.Printf("Warn: %#v\n", e)
        panic(e)
    }
}
