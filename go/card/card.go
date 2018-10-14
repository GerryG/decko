package card

import (
	"fmt"
	"os"
	"time"
)

type Card struct {
	//gorm.Model Can't have DeletedAt
	ID       uint   `gorm:"primary_key"`
	Name     string `gorm:"unique_index"`
	Key      string `gorm:"unique_index"`
	Codename string
	Left     *Card
	LeftID   uint
	Right    *Card
	RightID  uint
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
	Content           string // `sql:"db_content,type:text"`
	nodeRef           string
}

type ModCard struct {
	Name     string
	Codename string `yaml:",omitempty"`
	Codepath string `yaml:",omitempty"`
	Type     string
	Policy   string `yaml:",omitempty"`
}

var byid map[uint]uint = map[uint]uint{}

//var children [](map[string]uint)
//children = make([]map[string]uint, len(cards))

func (c *Card) Codepath(pcards *[]Card) string {
	if c.IsSimple() {
		return ""
	}
	leftcard := (*pcards)[byid[c.LeftID]]
	leftpath := ""
	if leftcard.IsSimple() {
		leftpath = leftcard.Code()
	} else if leftcard.Codename != "" {
		leftpath = leftcard.Codename
	} else {
		leftpath = leftcard.Codepath(pcards)
	}
	return leftpath + "/" + (*pcards)[byid[c.RightID]].Code()
}

func (c *Card) Code() string {
	cd := ":" + c.Codename
	if cd == ":" {
		cd = c.Key
	}
	if cd == "" {
		fmt.Fprintf(os.Stderr, "No codename or key %s\n", c.Name)
	}
	return cd
}

func (c *Card) IsSimple() bool {
	return c.RightID == 0
}

func ExportCards(pcards *[]Card) *[]ModCard {
	mcards := make([]ModCard, len(*pcards))
	for i, c := range *pcards {
		byid[c.ID] = uint(i)
	}

	for i, c := range *pcards {
		mcards[i] = ModCard{
			Name:     c.Name,
			Codename: c.Codename,
			Codepath: c.Codepath(pcards),
			Type:     (*pcards)[byid[c.TypeID]].Codename}
	}
	return &mcards
}
