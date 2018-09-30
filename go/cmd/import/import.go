
package main

import (
	"fmt"
	"time"
	"strings"
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
	Left              *Card    `json:"-"`
	LeftID            uint
	Right             *Card    `json:"-"`
	RightID           uint
	//CurrentRevision Revision // if we need to read revs (Act or Action?)
	CurrentRevisionID uint     `json:"-"`
	CreatedAt         time.Time
	UpdatedAt         time.Time
	Creator           *Card    `json:"-"`
	CreatorID         uint
	Updater           *Card    `json:"-"`
	UpdaterID         uint
	ReadRuleClass     string   `json:"-"`
	ReadRuleID        uint     `json:"-"`
	ReferencesExpired uint     `json:"-"`
	Trash             bool     `json:"-"`
	Type              *Card    `json:"-"`
	TypeID            uint
	Content string   `gorm:"column:db_content" sql:"type:text"` // text (large)
	//nodeRef string
}

var cards []Card
var byid  map[uint]uint = map[uint]uint{}
var children [](map[string]uint)

func id2card(id uint) *Card { return &cards[byid[id]] }
func id2children(id uint) map[string]uint { return children[byid[id]]}

var dbuser string = "root"
var dbpw string = "decko123"
var dbname string = "mydev_development"
var outdir string = "/home/gerry/seed_deck/"
var srcdir string = "/home/gerry/mydev/files"
var moddir string = "/home/gerry/go/src/github.com/GerryG/decko/card/mod"
var fileID uint = 18 // could find the type, but this is the only type in seeds with external files
var imageID uint = 19 // could find the type, but this is the only type in seeds with external files

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
	//fmt.Printf("Card: %#v\n", cards[1])
	//fmt.Printf("Card: %#v\n", cards[2])
        children = make([]map[string]uint, len(cards))
	errs = db.GetErrors()
	if len(errs) > 0 {
		panic(fmt.Sprintf("Error reading from db: %v", errs))
	}

	// Create node diretories and card detail objects
	for _, c := range cards {
		if !c.Trash {
			outputNode(&c)
		}
	}
}

func outputNode(c *Card) {
	nodepath := filepath.Join(outdir, strings.Replace(c.Key, "+", "/", -1))
	//fmt.Printf("Out:%s\n", nodepath)
	check(os.MkdirAll(nodepath, os.ModePerm))
	f, err := os.Create(filepath.Join(nodepath, "content.json"))
	check(err)
	defer f.Close()

	data, err := json.Marshal(c)
	check(err)
	n, err := f.Write(data)
	if n != len(data) {
		panic("Incomplete write")
	}

	if (c.TypeID == fileID || c.TypeID == imageID)&& c.Content != "" { // write the external file to node dir
		file, mod := path.Split(c.Content)
		file = file[:len(file)-1]
		split := strings.Split(mod, ".")
		mod = strings.Join(split[:len(split)-1], ".")
		var cfile, cdir string
		if file[0] == ':' {
			cdir = filepath.Join(moddir, mod, "file", file[1:])
		} else if file[0] == '~' {
			cfile = filepath.Join(srcdir, c.Content[1:])
		} else {
			cdir = filepath.Join(srcdir, c.Content)
		}
		//fmt.Printf("ext file c:%s, f:%s, m:%s, cd:%s\n", c.Content, file, mod,  cdir)
		if cfile != "" {
			_, fname := path.Split(cfile)
			copyFile(cfile, filepath.Join(nodepath, fname))
		} else {
			files, err := ioutil.ReadDir(cdir)
			check(err)
			for _, f := range files {
				fmt.Printf("copy file dir[%s] %s\n", cdir, f.Name())
				if f.IsDir() {
					fmt.Printf("Unexpected dir[%s] %s\n", cdir, f.Name())
				} else {
					copyFile(path.Join(cdir, f.Name()),
						filepath.Join(nodepath, f.Name()))
				}
			}
		}
	}
}

func copyFile(src, dst string) {
	dat, err := ioutil.ReadFile(src)
	if os.IsNotExist(err) {
		fmt.Printf("No file: %s\n", src)
	} else {
		check(err)
		check(ioutil.WriteFile(dst, dat, os.ModePerm))
	}
}

func check(e error) {
    if e != nil {
        //fmt.Printf("Warn: %#v\n", e)
        panic(e)
    }
}
