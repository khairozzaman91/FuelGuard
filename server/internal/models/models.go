package models

import (
	"time"
	
)

// User represents both Admin and Operator
type User struct {
    ID         string    `gorm:"type:uuid;primaryKey;default:uuid_generate_v4()" json:"id"`
    FullName   string    `gorm:"type:varchar(100);not null" json:"full_name"`
    Phone      string    `gorm:"type:varchar(20);unique;not null" json:"phone"`
    Password   string    `gorm:"type:varchar(255);not null" json:"password"`
    Role       string    `gorm:"type:varchar(20);default:'operator'" json:"role"` 
    IsApproved bool      `gorm:"default:false" json:"is_approved"`
    PumpName   string    `gorm:"type:varchar(100)" json:"pump_name"`
    Location   string    `gorm:"type:varchar(255)" json:"location"`
    StationID  string    `gorm:"type:varchar(50)" json:"station_id"` 
    CreatedAt  time.Time `json:"created_at"`
}

// Transaction represents fuel entry
type Transaction struct {
	ID              uint      `gorm:"primaryKey" json:"id"`
	StationID       string    `gorm:"type:varchar(50);index;not null" json:"station_id"` // SQL: station_id
	OperatorPhone   string    `gorm:"type:varchar(20);not null" json:"operator_phone"`   // SQL: operator_phone (নতুন যোগ করা হয়েছে)
	VehiclePlate    string    `gorm:"type:varchar(50);index;not null" json:"vehicle_plate"` // SQL: vehicle_plate
	FuelType        string    `gorm:"type:varchar(20);not null" json:"fuel_type"`       // SQL: fuel_type (নতুন যোগ করা হয়েছে)
	Liters          float64   `gorm:"not null" json:"liters"`                            // SQL: liters
	Amount          float64   `gorm:"not null" json:"amount"`                            // SQL: amount (নতুন যোগ করা হয়েছে)
	IsEmergency     bool      `gorm:"default:false" json:"is_emergency"`
	EmergencyReason string    `json:"emergency_reason"`
	NextEligibleDate time.Time `json:"next_eligible_date"`
	AssignedSlot    string    `json:"assigned_slot"`
	TransactionDate time.Time `gorm:"autoCreateTime" json:"transaction_date"`            // SQL: created_at এর কাজ করবে
}