package repository

import (
	"fuel-guard-backend/internal/config"
	"fuel-guard-backend/internal/models"
)

// CheckLastTransaction - গাড়ির প্লেট দিয়ে শেষ ট্রানজ্যাকশন বের করা
func CheckLastTransaction(plate string) (*models.Transaction, error) {
	var tx models.Transaction
	err := config.DB.Where("vehicle_plate = ?", plate).Order("transaction_date DESC").First(&tx).Error
	if err != nil {
		return nil, err
	}
	return &tx, nil
}

// SaveTransaction - নতুন ফুয়েল রেকর্ড সেভ করা
func SaveTransaction(tx *models.Transaction) error {
	return config.DB.Create(tx).Error
}

// GetHistoryByStation - পাম্পের আইডি দিয়ে সব হিস্ট্রি আনা (এটি মিসিং ছিল)
func GetHistoryByStation(stationID string) ([]models.Transaction, error) {
	var history []models.Transaction
	err := config.DB.Where("station_id = ?", stationID).Order("transaction_date DESC").Find(&history).Error
	return history, err
}