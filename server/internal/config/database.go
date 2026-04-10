package config

import (
	"context"
	"fmt"
	"fuel-guard-backend/internal/models"
	"log"
	"os"
	"time"
	"github.com/joho/godotenv"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

var DB *gorm.DB
 
func Connect() {
	_ = godotenv.Load()
	dbURL := os.Getenv("DATABASE_URL")
	if dbURL == "" {
		log.Fatal("❌ DATABASE_URL not found!")
	}

	db, err := gorm.Open(postgres.Open(dbURL), &gorm.Config{PrepareStmt: true})
	if err != nil {
		log.Fatal("❌ Connection Failed: ", err)
	}

	sqlDB, _ := db.DB()
	sqlDB.SetMaxIdleConns(10)
	sqlDB.SetMaxOpenConns(100)
	sqlDB.SetConnMaxLifetime(time.Hour)

	fmt.Println("✅ Connected to Supabase!")
	DB = db
	db.AutoMigrate(&models.User{}, &models.Transaction{})
	StartAutoCleanup()
}

func StartAutoCleanup() {
	go func() {
		ticker := time.NewTicker(24 * time.Hour)
		for range ticker.C {
			if DB == nil { continue }
			fourDaysAgo := time.Now().AddDate(0, 0, -4)
			ctx, cancel := context.WithTimeout(context.Background(), 2*time.Minute)
			// database.go ফাইলের ভেতরে এই লাইনটি আপডেট করুন
            DB.WithContext(ctx).Unscoped().Where("transaction_date < ?", fourDaysAgo).Delete(&models.Transaction{})
			cancel()
		}
	}()
}