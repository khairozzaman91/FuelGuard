package handlers

import (
	"fuel-guard-backend/internal/config"
	"fuel-guard-backend/internal/models"
	"fuel-guard-backend/internal/services"
	"net/http"

	"github.com/gin-gonic/gin"
	"golang.org/x/crypto/bcrypt"
)

// 🔐 LOGIN
func Login(c *gin.Context) {
	var input struct {
		Phone    string `json:"phone" binding:"required"`
		Password string `json:"password" binding:"required"`
	}

	// ✅ Input validation
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"error":   "Invalid input",
		})
		return
	}

	var user models.User

	// ✅ User check
	if err := config.DB.Where("phone = ?", input.Phone).First(&user).Error; err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{
			"success": false,
			"error":   "User not found",
		})
		return
	}

	// ✅ Password check
	if err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(input.Password)); err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{
			"success": false,
			"error":   "Wrong password",
		})
		return
	}

	// ✅ Operator approval check
	if user.Role == "operator" && !user.IsApproved {
		c.JSON(http.StatusForbidden, gin.H{
			"success": false,
			"error":   "Not approved yet",
		})
		return
	}

	// ✅ Generate token (safe)
	token, err := services.GenerateToken(user.Phone, user.Role)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"error":   "Token generation failed",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data": gin.H{
			"token": token,
			"user":  user,
		},
	})
}





// 📝 REGISTER
func Register(c *gin.Context) {
	var user models.User

	// ✅ Input validation
	if err := c.ShouldBindJSON(&user); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"error":   "Invalid input",
		})
		return
	}

	// ⚠️ Extra: password empty check (important)
	if user.Password == "" {
		c.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"error":   "Password required",
		})
		return
	}

	// ✅ Password hash (safe)
	hashed, err := bcrypt.GenerateFromPassword([]byte(user.Password), 10)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"error":   "Password hash failed",
		})
		return
	}

	user.Password = string(hashed)
	user.Role = "operator"
	user.IsApproved = false

	// ⚠️ Extra: duplicate phone check (recommended)
	var existing models.User
	if err := config.DB.Where("phone = ?", user.Phone).First(&existing).Error; err == nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"error":   "Phone already registered",
		})
		return
	}

	// ✅ Save user with error check
	if err := config.DB.Create(&user).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"error":   "Registration failed",
		})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"success": true,
		"message": "Registered. Wait for approval.",
	})
}