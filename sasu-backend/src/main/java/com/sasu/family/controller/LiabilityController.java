package com.sasu.family.controller;

import com.sasu.family.model.Liability;
import com.sasu.family.service.LiabilityService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Liability Controller
 *
 * ADMIN: Full CRUD access
 * FAMILY: Read-only access
 */
@RestController
@RequestMapping("/api/liabilities")
@RequiredArgsConstructor
public class LiabilityController {

    private final LiabilityService liabilityService;

    @GetMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'FAMILY')")
    public ResponseEntity<List<Liability>> getAllLiabilities() {
        return ResponseEntity.ok(liabilityService.getAllLiabilities());
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'FAMILY')")
    public ResponseEntity<Liability> getLiabilityById(@PathVariable Long id) {
        return ResponseEntity.ok(liabilityService.getLiabilityById(id));
    }

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Liability> createLiability(@RequestBody Liability liability) {
        return ResponseEntity.ok(liabilityService.createLiability(liability));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Liability> updateLiability(@PathVariable Long id, @RequestBody Liability liability) {
        return ResponseEntity.ok(liabilityService.updateLiability(id, liability));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> deleteLiability(@PathVariable Long id) {
        liabilityService.deleteLiability(id);
        return ResponseEntity.ok("Liability deleted successfully");
    }
}

