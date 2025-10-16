package com.idap.repository;

import com.idap.entity.Sales;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

/**
 * 销售记录 Repository
 */
@Repository
public interface SalesRepository extends JpaRepository<Sales, Long> {

    /**
     * 根据订单号查找
     */
    List<Sales> findByOrderId(String orderId);

    /**
     * 根据客户ID查找销售记录
     */
    List<Sales> findByCustomer_CustomerId(Long customerId);

    /**
     * 根据产品ID查找销售记录
     */
    List<Sales> findByProduct_ProductId(Long productId);

    /**
     * 根据销售日期范围查找
     */
    List<Sales> findBySaleDateBetween(LocalDate startDate, LocalDate endDate);

    /**
     * 根据地区查找销售记录
     */
    List<Sales> findByRegion(String region);

    /**
     * 根据渠道查找销售记录
     */
    List<Sales> findByChannel(Sales.SalesChannel channel);

    /**
     * 查找某个时间段的销售记录（分页）
     */
    Page<Sales> findBySaleDateBetween(LocalDate startDate, LocalDate endDate, Pageable pageable);

    /**
     * 统计日期范围内的总销售额
     */
    @Query("SELECT SUM(s.totalAmount) FROM Sales s WHERE s.saleDate BETWEEN :startDate AND :endDate")
    BigDecimal calculateTotalRevenue(@Param("startDate") LocalDate startDate,
            @Param("endDate") LocalDate endDate);

    /**
     * 统计日期范围内的订单数
     */
    @Query("SELECT COUNT(DISTINCT s.orderId) FROM Sales s WHERE s.saleDate BETWEEN :startDate AND :endDate")
    Long countOrders(@Param("startDate") LocalDate startDate,
            @Param("endDate") LocalDate endDate);

    /**
     * 查找Top N畅销产品
     */
    @Query("SELECT s.product.productId, s.product.productName, SUM(s.quantity) as totalQty, " +
            "SUM(s.totalAmount) as totalRevenue " +
            "FROM Sales s " +
            "WHERE s.saleDate BETWEEN :startDate AND :endDate " +
            "GROUP BY s.product.productId, s.product.productName " +
            "ORDER BY totalRevenue DESC")
    List<Object[]> findTopSellingProducts(@Param("startDate") LocalDate startDate,
            @Param("endDate") LocalDate endDate,
            Pageable pageable);

    /**
     * 按地区统计销售额
     */
    @Query("SELECT s.region, SUM(s.totalAmount), COUNT(s) " +
            "FROM Sales s " +
            "WHERE s.saleDate BETWEEN :startDate AND :endDate " +
            "GROUP BY s.region " +
            "ORDER BY SUM(s.totalAmount) DESC")
    List<Object[]> calculateRevenueByRegion(@Param("startDate") LocalDate startDate,
            @Param("endDate") LocalDate endDate);

    /**
     * 按渠道统计销售额
     */
    @Query("SELECT s.channel, SUM(s.totalAmount), COUNT(s) " +
            "FROM Sales s " +
            "WHERE s.saleDate BETWEEN :startDate AND :endDate " +
            "GROUP BY s.channel " +
            "ORDER BY SUM(s.totalAmount) DESC")
    List<Object[]> calculateRevenueByChannel(@Param("startDate") LocalDate startDate,
            @Param("endDate") LocalDate endDate);

    /**
     * 按日期统计每日销售额（用于趋势分析）
     */
    @Query("SELECT s.saleDate, SUM(s.totalAmount), COUNT(DISTINCT s.orderId) " +
            "FROM Sales s " +
            "WHERE s.saleDate BETWEEN :startDate AND :endDate " +
            "GROUP BY s.saleDate " +
            "ORDER BY s.saleDate")
    List<Object[]> calculateDailySales(@Param("startDate") LocalDate startDate,
            @Param("endDate") LocalDate endDate);
}
