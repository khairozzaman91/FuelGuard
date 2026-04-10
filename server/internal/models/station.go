package models

import "time"

// Station represents a Fuel Pump Station in the system
type Station struct {
	ID         int       `json:"id"`
	Name       string    `json:"name"`       
	Location   string    `json:"location"`   
	Phone      string    `json:"phone"`     
	OperatorID int       `json:"operator_id"` 
	CreatedAt  time.Time `json:"created_at"`
}