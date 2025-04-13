// Utility functions for handling response formatting

// Success response
exports.successResponse = (res, message, data) => {
    return res.status(200).json({
      success: true,
      message,
      data,
    });
  };
  
  // Error response
  exports.errorResponse = (res, message, error) => {
    return res.status(500).json({
      success: false,
      message,
      error,
    });
  };
  