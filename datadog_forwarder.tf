resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_logger.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.secure_bucket.arn
}