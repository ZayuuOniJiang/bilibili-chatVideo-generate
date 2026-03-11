package org.example.pojo;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 接口错误信息（用于异常响应）
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ApiError implements Serializable {

    private static final long serialVersionUID = 1L;

    private int code;
    private String message;
    private String path;
    private LocalDateTime timestamp;
}
