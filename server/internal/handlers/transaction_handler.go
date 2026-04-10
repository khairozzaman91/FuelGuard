package handlers

import (
	"fuel-guard-backend/internal/models"
	"fuel-guard-backend/internal/repository"
	"fuel-guard-backend/internal/services"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
)

// CheckEligibility - গাড়ি আজ তেল পাবে কি না চেক করা
func CheckEligibility(c *gin.Context) {
	var input struct {
		Plate string `json:"vehicle_plate" binding:"required"`
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": "গাড়ির প্লেট নম্বর দিন"})
		return
	}

	lastTx, err := repository.CheckLastTransaction(input.Plate)
	if err != nil && err.Error() != "record not found" {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "error": "সার্ভার এরর"})
		return
	}

	if lastTx != nil && time.Now().Before(lastTx.NextEligibleDate) {
		c.JSON(http.StatusOK, gin.H{
			"success":            true,
			"eligible":           false,
			"message":            "৩ দিনের নিয়ম ভঙ্গ হয়েছে!",
			"next_eligible_date": lastTx.NextEligibleDate.Format("02 Jan 2006"),
			"assigned_slot":      lastTx.AssignedSlot,
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "eligible": true, "message": "গাড়িটি অনুমোদিত"})
}

// SubmitFuel - নতুন ট্রানজ্যাকশন সেভ করা
func SubmitFuel(c *gin.Context) {
	var input struct {
		VehiclePlate    string  `json:"vehicle_plate" binding:"required"`
		StationID       string  `json:"station_id" binding:"required"`
		OperatorPhone   string  `json:"operator_phone" binding:"required"`
		FuelType        string  `json:"fuel_type" binding:"required"`
		Liters          float64 `json:"liters" binding:"required"`
		Amount          float64 `json:"amount" binding:"required"`
		IsEmergency     bool    `json:"is_emergency"`
		EmergencyReason string  `json:"emergency_reason"`
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": "সব তথ্য দিন"})
		return
	}

	nextDate, slot := services.CalculateNextRefill()

	newTx := models.Transaction{
		VehiclePlate:     input.VehiclePlate,
		StationID:        input.StationID,
		OperatorPhone:    input.OperatorPhone,
		FuelType:         input.FuelType,
		Liters:           input.Liters,
		Amount:           input.Amount,
		IsEmergency:      input.IsEmergency,
		EmergencyReason:  input.EmergencyReason,
		NextEligibleDate: nextDate,
		AssignedSlot:     slot,
		TransactionDate:  time.Now(),
	}

	if err := repository.SaveTransaction(&newTx); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "error": "সেভ ব্যর্থ হয়েছে"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "message": "সফল হয়েছে", "data": gin.H{"next_date": nextDate.Format("02 Jan 2006"), "slot": slot}})
}

// GetFuelHistory - হিস্ট্রি দেখা
func GetFuelHistory(c *gin.Context) {
	stationID := c.Query("station_id")
	if stationID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "error": "Station ID প্রয়োজন"})
		return
	}
	
	history, err := repository.GetHistoryByStation(stationID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "error": "হিস্ট্রি পাওয়া যায়নি"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "data": history})
}