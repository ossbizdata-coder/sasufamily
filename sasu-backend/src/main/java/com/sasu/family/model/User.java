package com.sasu.family.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * User Model
 *
 * Represents family members with role-based access.
 *
 * Roles:
 * - ADMIN: Father/Husband (full CRUD access)
 * - FAMILY: Wife, Daughter (read-only access)
 */
@Entity
@Table(name = "users")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    @Builder.Default
    private Boolean active = true;

    @Column(name = "full_name", nullable = false)
    private String fullName;

    @Column(nullable = false)
    private String password;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private UserRole role;

    @Column(unique = true, nullable = false)
    private String username;


    public enum UserRole {
        ADMIN,    // Full access
        FAMILY    // Read-only
    }
}

