package handlers

import (
	"fuel-guard-backend/internal/config"
	"fuel-guard-backend/internal/models"
	"time"
	"github.com/gin-gonic/gin"
)

func GetPendingOperators(c *gin.Context) {
	var users []models.User
	config.DB.Where("is_approved = ? AND role = ?", false, "operator").Find(&users)
	c.JSON(200, gin.H{"success": true, "data": users})
}

func ApproveOperator(c *gin.Context) {
	var input struct { Phone string `json:"phone"` }
	c.ShouldBindJSON(&input)
	config.DB.Model(&models.User{}).Where("phone = ?", input.Phone).Update("is_approved", true)
	c.JSON(200, gin.H{"success": true, "message": "Approved!"})
}

func GetLiveStats(c *gin.Context) {
	var stats []struct {
		StationID   string  `json:"station_id"`
		TotalLiters float64 `json:"total_liters"`
		TotalCars   int64   `json:"total_cars"`
	}
	today := time.Now().Truncate(24 * time.Hour)
	config.DB.Model(&models.Transaction{}).Select("station_id, sum(liters) as total_liters, count(id) as total_cars").Where("transaction_date >= ?", today).Group("station_id").Scan(&stats)
	c.JSON(200, gin.H{"success": true, "data": stats})
}

func GetStationDetails(c *gin.Context) {
	stationID := c.Param("id")
	var transactions []models.Transaction
	config.DB.Where("station_id = ?", stationID).Order("created_at desc").Find(&transactions)
	c.JSON(200, gin.H{"success": true, "data": transactions})
}

func GetProfile(c *gin.Context) {
	phone, _ := c.Get("user_phone")
	var user models.User
	if err := config.DB.Where("phone = ?", phone).First(&user).Error; err != nil {
		c.JSON(404, gin.H{"success": false, "error": "Profile not found"})
		return
	}
	c.JSON(200, gin.H{"success": true, "data": user})
}

func UpdateProfile(c *gin.Context) {
	phone, _ := c.Get("user_phone")
	var input map[string]interface{}
	c.ShouldBindJSON(&input)
	config.DB.Model(&models.User{}).Where("phone = ?", phone).Updates(input)
	c.JSON(200, gin.H{"success": true, "message": "Updated!"})
}