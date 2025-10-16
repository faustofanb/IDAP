package com.idap.repository;

import com.idap.entity.Feedback;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 用户反馈 Repository
 */
@Repository
public interface FeedbackRepository extends JpaRepository<Feedback, Long> {

    /**
     * 根据查询ID查找反馈
     */
    List<Feedback> findByQuery_QueryId(Long queryId);

    /**
     * 根据用户ID查找反馈
     */
    Page<Feedback> findByUser_UserId(Long userId, Pageable pageable);

    /**
     * 根据评分查找反馈
     */
    List<Feedback> findByRating(Integer rating);

    /**
     * 查找评分小于等于指定值的反馈（差评）
     */
    @Query("SELECT f FROM Feedback f WHERE f.rating <= :threshold ORDER BY f.createdAt DESC")
    List<Feedback> findLowRatingFeedback(@Param("threshold") Integer threshold);

    /**
     * 查找评分大于等于指定值的反馈（好评）
     */
    @Query("SELECT f FROM Feedback f WHERE f.rating >= :threshold ORDER BY f.createdAt DESC")
    List<Feedback> findHighRatingFeedback(@Param("threshold") Integer threshold);

    /**
     * 统计平均评分
     */
    @Query("SELECT AVG(f.rating) FROM Feedback f")
    Double calculateAverageRating();

    /**
     * 统计时间范围内的平均评分
     */
    @Query("SELECT AVG(f.rating) FROM Feedback f WHERE f.createdAt BETWEEN :startTime AND :endTime")
    Double calculateAverageRating(@Param("startTime") LocalDateTime startTime,
            @Param("endTime") LocalDateTime endTime);

    /**
     * 按评分统计反馈数量
     */
    @Query("SELECT f.rating, COUNT(f) FROM Feedback f GROUP BY f.rating ORDER BY f.rating DESC")
    List<Object[]> countByRating();

    /**
     * 查找有文本反馈的记录
     */
    @Query("SELECT f FROM Feedback f WHERE f.feedbackText IS NOT NULL AND f.feedbackText <> '' " +
            "ORDER BY f.createdAt DESC")
    Page<Feedback> findFeedbackWithText(Pageable pageable);
}
