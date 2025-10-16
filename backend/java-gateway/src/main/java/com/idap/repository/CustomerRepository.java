package com.idap.repository;

import com.idap.entity.Customer;
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
 * 客户 Repository
 */
@Repository
public interface CustomerRepository extends JpaRepository<Customer, Long> {

    /**
     * 根据客户名称查找
     */
    Optional<Customer> findByCustomerName(String customerName);

    /**
     * 根据邮箱查找
     */
    Optional<Customer> findByEmail(String email);

    /**
     * 根据手机号查找
     */
    Optional<Customer> findByPhone(String phone);

    /**
     * 根据地区查找客户
     */
    List<Customer> findByRegion(String region);

    /**
     * 根据城市查找客户
     */
    List<Customer> findByCity(String city);

    /**
     * 根据会员级别查找客户
     */
    List<Customer> findByMembershipLevel(Customer.MembershipLevel level);

    /**
     * 根据会员级别分页查找
     */
    Page<Customer> findByMembershipLevel(Customer.MembershipLevel level, Pageable pageable);

    /**
     * 查找消费金额大于指定值的客户
     */
    @Query("SELECT c FROM Customer c WHERE c.totalSpent > :minSpent ORDER BY c.totalSpent DESC")
    List<Customer> findHighValueCustomers(@Param("minSpent") BigDecimal minSpent);

    /**
     * 查找特定地区的高价值客户
     */
    @Query("SELECT c FROM Customer c WHERE c.region = :region AND c.totalSpent > :minSpent " +
            "ORDER BY c.totalSpent DESC")
    List<Customer> findHighValueCustomersByRegion(@Param("region") String region,
            @Param("minSpent") BigDecimal minSpent);

    /**
     * 按地区统计客户数量
     */
    @Query("SELECT c.region, COUNT(c) FROM Customer c GROUP BY c.region")
    List<Object[]> countByRegion();

    /**
     * 按会员级别统计客户数量
     */
    @Query("SELECT c.membershipLevel, COUNT(c) FROM Customer c GROUP BY c.membershipLevel")
    List<Object[]> countByMembershipLevel();
}
