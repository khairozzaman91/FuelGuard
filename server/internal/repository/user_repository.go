package repository

import (
	"errors"
	"fuel-guard-backend/internal/config" 
	"fuel-guard-backend/internal/models"
	"gorm.io/gorm"
)

// CreateUser saves a new user application
func CreateUser(user *models.User) error {
	// database.DB এর বদলে config.DB ব্যবহার করতে হবে
	return config.DB.Create(user).Error
}

// GetUserByPhone finds a user by their phone number for login
func GetUserByPhone(phone string) (*models.User, error) {
	var user models.User
	// config.DB ব্যবহার করা হয়েছে
	err := config.DB.Where("phone = ?", phone).First(&user).Error
	
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, nil
		}
		return nil, err
	}
	return &user, nil
}

// GetPendingUsers fetches all users who are not yet approved (Admin only)
func GetPendingUsers() ([]models.User, error) {
	var users []models.User
	// config.DB ব্যবহার করা হয়েছে
	err := config.DB.Where("is_approved = ?", false).Find(&users).Error
	return users, err
}

// ApproveUser sets is_approved to true for a specific user phone
func ApproveUser(phone string) error {
	// config.DB ব্যবহার করা হয়েছে
	return config.DB.Model(&models.User{}).Where("phone = ?", phone).Update("is_approved", true).Error
}

// ApproveUserByID sets is_approved to true for a specific user ID
func ApproveUserByID(id string) error {
    return config.DB.Model(&models.User{}).Where("id = ?", id).Update("is_approved", true).Error
}