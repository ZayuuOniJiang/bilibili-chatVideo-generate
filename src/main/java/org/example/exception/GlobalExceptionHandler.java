package org.example.exception;

import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.validation.BindException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.multipart.MaxUploadSizeExceededException;
import org.springframework.web.servlet.NoHandlerFoundException;

import javax.servlet.http.HttpServletRequest;
import java.util.stream.Collectors;

/**
 * 全局异常处理器：统一返回 JSON
 */
@Slf4j
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(BusinessException.class)
    @ResponseStatus(HttpStatus.OK)
    public org.example.pojo.Result<Void> handleBusinessException(BusinessException e, HttpServletRequest request) {
        log.warn("业务异常: code={}, msg={}", e.getCode(), e.getMessage());
        return org.example.pojo.Result.fail(e.getCode(), e.getMessage());
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public org.example.pojo.Result<Void> handleValidation(MethodArgumentNotValidException e, HttpServletRequest request) {
        String msg = e.getBindingResult().getFieldErrors().stream()
                .map(err -> err.getField() + ": " + err.getDefaultMessage())
                .collect(Collectors.joining("; "));
        log.warn("参数校验失败: {}", msg);
        return org.example.pojo.Result.fail(400, msg);
    }

    @ExceptionHandler(BindException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public org.example.pojo.Result<Void> handleBind(BindException e, HttpServletRequest request) {
        String msg = e.getBindingResult().getFieldErrors().stream()
                .map(err -> err.getField() + ": " + err.getDefaultMessage())
                .collect(Collectors.joining("; "));
        log.warn("绑定异常: {}", msg);
        return org.example.pojo.Result.fail(400, msg);
    }

    @ExceptionHandler(NoHandlerFoundException.class)
    @ResponseStatus(HttpStatus.NOT_FOUND)
    public org.example.pojo.Result<Void> handle404(NoHandlerFoundException e, HttpServletRequest request) {
        log.warn("404: {}", e.getRequestURL());
        return org.example.pojo.Result.fail(404, "接口不存在: " + e.getRequestURL());
    }

    @ExceptionHandler(MaxUploadSizeExceededException.class)
    @ResponseStatus(HttpStatus.PAYLOAD_TOO_LARGE)
    public org.example.pojo.Result<Void> handleMaxUploadSizeExceeded(MaxUploadSizeExceededException e, HttpServletRequest request) {
        log.warn("上传文件过大: {}", e.getMessage());
        return org.example.pojo.Result.fail(413, "上传文件过大，请确保单文件不超过 50MB");
    }

    @ExceptionHandler(Exception.class)
    @ResponseStatus(HttpStatus.INTERNAL_SERVER_ERROR)
    public org.example.pojo.Result<Void> handleException(Exception e, HttpServletRequest request) {
        log.error("未捕获异常: path={}", request.getRequestURI(), e);
        return org.example.pojo.Result.fail(500, "服务器内部错误: " + e.getMessage());
    }
}
