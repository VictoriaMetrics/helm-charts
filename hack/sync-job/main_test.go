package main

import (
	"fmt"
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestFetchReturnsErrorOn4xx(t *testing.T) {
	for _, code := range []int{http.StatusNotFound, http.StatusForbidden, http.StatusUnauthorized} {
		t.Run(fmt.Sprintf("HTTP %d", code), func(t *testing.T) {
			srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
				w.WriteHeader(code)
			}))
			defer srv.Close()
			_, err := fetch(srv.URL)
			if err == nil {
				t.Fatalf("expected error for HTTP %d, got nil", code)
			}
		})
	}
}

func TestFetchRetriesOn429(t *testing.T) {
	attempts := 0
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		attempts++
		if attempts < 3 {
			w.WriteHeader(http.StatusTooManyRequests)
			return
		}
		w.WriteHeader(http.StatusOK)
		w.Write([]byte("ok"))
	}))
	defer srv.Close()

	data, err := fetch(srv.URL)
	if err != nil {
		t.Fatalf("expected success after retries, got: %v", err)
	}
	if string(data) != "ok" {
		t.Fatalf("unexpected body: %q", data)
	}
	if attempts != 3 {
		t.Fatalf("expected 3 attempts, got %d", attempts)
	}
}

func TestFetchReturnsErrorOn5xx(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusInternalServerError)
	}))
	defer srv.Close()

	_, err := fetch(srv.URL)
	if err == nil {
		t.Fatal("expected error for HTTP 500, got nil")
	}
}
