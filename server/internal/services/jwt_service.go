package services

import (
	"errors"
	"os"
	"time"

	"github.com/golang-jwt/jwt/v5"
)

// 🔐 get secret from ENV
func getSecret() []byte {
    secret := os.Getenv("JWT_SECRET")
    if secret == "" {
        return []byte("fuel_guard_secret_2026") 
    }
    return []byte(secret)
}

var jwtSecret = getSecret()

// 🔐 GenerateToken
func GenerateToken(phone string, role string) (string, error) {
	claims := jwt.MapClaims{
		"phone": phone,
		"role":  role,
		"exp":   time.Now().Add(time.Hour * 72).Unix(),
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString(jwtSecret)
}

// 🔐 ValidateToken (improved)
func ValidateToken(tokenStr string) (string, string, error) {
	token, err := jwt.Parse(tokenStr, func(t *jwt.Token) (interface{}, error) {
		// ✅ check signing method (security best practice)
		if _, ok := t.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, errors.New("invalid signing method")
		}
		return jwtSecret, nil
	})

	if err != nil {
		return "", "", err
	}

	claims, ok := token.Claims.(jwt.MapClaims)
	if !ok || !token.Valid {
		return "", "", errors.New("invalid token")
	}

	phone, _ := claims["phone"].(string)
	role, _ := claims["role"].(string)

	return phone, role, nil
}