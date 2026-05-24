package com.tradeflow.notification_service;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/notifications")
public class PaymentNotificationController {

    private final PaymentNotificationRepository repository;

    public PaymentNotificationController(PaymentNotificationRepository repository) {
        this.repository = repository;
    }

    @PostMapping
    public ResponseEntity<PaymentNotification> create(
            @RequestBody PaymentNotification notification) {
        PaymentNotification saved = repository.save(notification);
        return ResponseEntity.ok(saved);
    }

    @GetMapping
    public ResponseEntity<List<PaymentNotification>> getAll() {
        return ResponseEntity.ok(repository.findAll());
    }

    @GetMapping("/{id}")
    public ResponseEntity<PaymentNotification> getById(@PathVariable Long id) {
        return repository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/status/{status}")
    public ResponseEntity<List<PaymentNotification>> getByStatus(
            @PathVariable String status) {
        return ResponseEntity.ok(repository.findByStatus(status));
    }

    @PutMapping("/{id}/status")
    public ResponseEntity<PaymentNotification> updateStatus(
            @PathVariable Long id, @RequestParam String status) {
        return repository.findById(id).map(n -> {
            n.setStatus(status);
            return ResponseEntity.ok(repository.save(n));
        }).orElse(ResponseEntity.notFound().build());
    }
}