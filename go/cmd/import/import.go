package main

import (
	"fmt"
	//"math/big"

	//"strconv"

	"github.com/GerryG/decko/go/card"
	"github.com/jinzhu/gorm"
	_ "github.com/jinzhu/gorm/dialects/mysql"
	"gopkg.in/yaml.v2"
)

var cards []card.Card

var yamlExport bool = true

//func id2card(id uint) *Card               { return &cards[byid[id]] }
//func id2children(id uint) map[string]uint { return children[byid[id]] }

func main() {
	dbuser := "root"
	dbpw := "decko123"
	dbname := "seedsite_production"
	cstring := dbuser + ":" + dbpw + "@/" + dbname + "?charset=utf8&parseTime=True&loc=Local"
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
	errs = db.GetErrors()
	if len(errs) > 0 {
		panic(fmt.Sprintf("Error reading from db: %v", errs))
	}

	mcards := card.ExportCards(&cards)

	if yamlExport {
		yslice, err := yaml.Marshal(*mcards)
		if err != nil {
			panic(fmt.Sprintf("Error from yaml marshal %v", err))
		}
		fmt.Print(string(yslice))
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
	/*for _, c := range cards {
		//fmt.Printf("ccH1:key:%s\n", c.Key)
		computeHash("", &c)
	}*/
}
