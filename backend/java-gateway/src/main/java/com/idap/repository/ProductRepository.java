package com.idap.repository;

import com.idap.entity.Product;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

/**
 * 产品 Repository
 */
@Repository
public interface ProductRepository extends JpaRepository<Product, Long> {

    /**
     * 根据产品名称查找
     */
    Optional<Product> findByProductName(String productName);

    /**
     * 根据分类查找产品
     */
    List<Product> findByCategory(String category);

    /**
     * 根据品牌查找产品
     */
    List<Product> findByBrand(String brand);

    /**
     * 根据分类分页查找
     */
    Page<Product> findByCategory(String category, Pageable pageable);

    /**
     * 查找价格区间内的产品
     */
    @Query("SELECT p FROM Product p WHERE p.price BETWEEN :minPrice AND :maxPrice")
    List<Product> findByPriceRange(@Param("minPrice") BigDecimal minPrice,
            @Param("maxPrice") BigDecimal maxPrice);

    /**
     * 查找库存不足的产品
     */
    @Query("SELECT p FROM Product p WHERE p.stockQuantity < :threshold")
    List<Product> findLowStockProducts(@Param("threshold") Integer threshold);

    /**
     * 按分类统计产品数量
     */
    @Query("SELECT p.category, COUNT(p) FROM Product p GROUP BY p.category")
    List<Object[]> countByCategory();
}
