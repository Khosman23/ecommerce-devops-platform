package main

import (
	"encoding/json"
	"log"
	"net/http"
	"os"
	"strconv"
	"strings"
	"time"
)

type Product struct {
	ID       int     `json:"id"`
	Name     string  `json:"name"`
	Price    float64 `json:"price"`
	Stock    int     `json:"stock"`
	Category string  `json:"category"`
}

type HealthResponse struct {
	Status    string `json:"status"`
	Service   string `json:"service"`
	Timestamp string `json:"timestamp"`
}

var productsDB = map[int]Product{
	1: {ID: 1, Name: "Laptop", Price: 999.99, Stock: 50, Category: "Electronics"},
	2: {ID: 2, Name: "Phone", Price: 499.99, Stock: 100, Category: "Electronics"},
	3: {ID: 3, Name: "Desk Chair", Price: 299.99, Stock: 30, Category: "Furniture"},
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(HealthResponse{
		Status:    "healthy",
		Service:   "product-service",
		Timestamp: time.Now().UTC().Format(time.RFC3339),
	})
}

func productsHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")

	// GET /products
	if r.Method == http.MethodGet && r.URL.Path == "/products" {
		products := make([]Product, 0, len(productsDB))
		for _, p := range productsDB {
			products = append(products, p)
		}
		json.NewEncoder(w).Encode(map[string]interface{}{
			"products": products,
			"total":    len(products),
		})
		return
	}

	// GET /products/{id}
	if r.Method == http.MethodGet && strings.HasPrefix(r.URL.Path, "/products/") {
		idStr := strings.TrimPrefix(r.URL.Path, "/products/")
		id, err := strconv.Atoi(idStr)
		if err != nil {
			http.Error(w, `{"error":"invalid id"}`, http.StatusBadRequest)
			return
		}
		product, exists := productsDB[id]
		if !exists {
			http.Error(w, `{"error":"product not found"}`, http.StatusNotFound)
			return
		}
		json.NewEncoder(w).Encode(product)
		return
	}

	http.Error(w, `{"error":"not found"}`, http.StatusNotFound)
}

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "3002"
	}

	http.HandleFunc("/health", healthHandler)
	http.HandleFunc("/products", productsHandler)
	http.HandleFunc("/products/", productsHandler)

	log.Printf("Product Service running on port %s", port)
	log.Fatal(http.ListenAndServe(":"+port, nil))
}