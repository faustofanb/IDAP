package com.idap.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 客户实体类
 * 对应数据库表: customers
 */
@Entity
@Table(name = "customers", indexes = {
        @Index(name = "idx_customers_region", columnList = "region"),
        @Index(name = "idx_customers_city", columnList = "city"),
        @Index(name = "idx_customers_membership_level", columnList = "membership_level")
})
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Customer {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "customer_id")
    private Long customerId;

    @Column(name = "customer_name", nullable = false, length = 100)
    private String customerName;

    @Column(name = "email", length = 100)
    private String email;

    @Column(name = "phone", length = 20)
    private String phone;

    @Column(name = "gender", length = 10)
    private String gender;

    @Column(name = "birth_date")
    private LocalDate birthDate;

    @Column(name = "region", length = 50)
    private String region;

    @Column(name = "city", length = 50)
    private String city;

    @Enumerated(EnumType.STRING)
    @Column(name = "membership_level", length = 20)
    @Builder.Default
    private MembershipLevel membershipLevel = MembershipLevel.REGULAR;

    @Column(name = "total_spent", precision = 12, scale = 2)
    @Builder.Default
    private BigDecimal totalSpent = BigDecimal.ZERO;

    @Column(name = "order_count")
    @Builder.Default
    private Integer orderCount = 0;

    @Column(name = "first_purchase_date")
    private LocalDate firstPurchaseDate;

    @Column(name = "last_purchase_date")
    private LocalDate lastPurchaseDate;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    /**
     * 会员级别枚举
     */
    public enum MembershipLevel {
        REGULAR("regular"),
        SILVER("silver"),
        GOLD("gold"),
        PLATINUM("platinum");

        private final String value;

        MembershipLevel(String value) {
            this.value = value;
        }

        public String getValue() {
            return value;
        }
    }
}
