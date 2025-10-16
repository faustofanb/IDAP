package com.idap.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 销售记录实体类
 * 对应数据库表: sales
 */
@Entity
@Table(name = "sales", indexes = {
        @Index(name = "idx_sales_product_id", columnList = "product_id"),
        @Index(name = "idx_sales_customer_id", columnList = "customer_id"),
        @Index(name = "idx_sales_sale_date", columnList = "sale_date"),
        @Index(name = "idx_sales_region", columnList = "region"),
        @Index(name = "idx_sales_channel", columnList = "channel"),
        @Index(name = "idx_sales_order_id", columnList = "order_id")
})
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Sales {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "sale_id")
    private Long saleId;

    @Column(name = "order_id", nullable = false, length = 100)
    private String orderId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id", referencedColumnName = "product_id")
    private Product product;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "customer_id", referencedColumnName = "customer_id")
    private Customer customer;

    @Column(name = "quantity", nullable = false)
    @Builder.Default
    private Integer quantity = 1;

    @Column(name = "unit_price", nullable = false, precision = 10, scale = 2)
    private BigDecimal unitPrice;

    @Column(name = "total_amount", nullable = false, precision = 12, scale = 2)
    private BigDecimal totalAmount;

    @Column(name = "discount_amount", precision = 10, scale = 2)
    @Builder.Default
    private BigDecimal discountAmount = BigDecimal.ZERO;

    @Column(name = "region", length = 50)
    private String region;

    @Column(name = "city", length = 50)
    private String city;

    @Column(name = "salesperson", length = 50)
    private String salesperson;

    @Enumerated(EnumType.STRING)
    @Column(name = "channel", length = 20)
    private SalesChannel channel;

    @Column(name = "sale_date", nullable = false)
    private LocalDate saleDate;

    @Column(name = "sale_time", nullable = false)
    @Builder.Default
    private LocalDateTime saleTime = LocalDateTime.now();

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    /**
     * 销售渠道枚举
     */
    public enum SalesChannel {
        ONLINE("online"),
        OFFLINE("offline"),
        MOBILE("mobile"),
        APP("app"),
        WECHAT("wechat");

        private final String value;

        SalesChannel(String value) {
            this.value = value;
        }

        public String getValue() {
            return value;
        }
    }
}
