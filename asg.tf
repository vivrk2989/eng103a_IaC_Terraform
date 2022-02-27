resource "aws_launch_configuration" "vivek" {
  name_prefix     = "tf-asg-vivek"
  image_id        = "ami-07d8796a2b0f8d29c"
  instance_type   = "t2.micro"
  security_groups = ["sg-008fff4be8213dc08"]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "vivek" {
  min_size             = 1
  max_size             = 3
  desired_capacity     = 1
  launch_configuration = aws_launch_configuration.vivek.name
  vpc_zone_identifier  = ["subnet-0bceb6d55d1aea11c"]
}

resource "aws_lb" "vivek" {
  name               = "vivek-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["sg-008fff4be8213dc08"]
  subnets            = ["subnet-0bceb6d55d1aea11c", "subnet-0808ddfdbf30229cd"]
}

resource "aws_lb_listener" "vivek" {
  load_balancer_arn = aws_lb.vivek.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.vivek.arn
  }
}

resource "aws_lb_target_group" "vivek" {
  name     = "vivek-tf-asg-practice"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "vpc-0aa5deac0f5187b98"
}

resource "aws_autoscaling_attachment" "vivek" {
  autoscaling_group_name = aws_autoscaling_group.vivek.id
  alb_target_group_arn   = aws_lb_target_group.vivek.arn
}

resource "aws_autoscaling_policy" "vivek_scale_up" {
  name                   = "vivek-scale-up"
  autoscaling_group_name = aws_autoscaling_group.vivek.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 300
}

resource "aws_autoscaling_policy" "vivek_scale_down" {
  name                   = "vivek-scale-down"
  autoscaling_group_name = aws_autoscaling_group.vivek.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 300

}

resource "aws_cloudwatch_metric_alarm" "vivek_scale_up_alarm" {
  alarm_description   = "Monitors CPU utilization for app"
  alarm_actions       = [aws_autoscaling_policy.vivek_scale_up.arn]
  alarm_name          = "vivek_scale_up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  threshold           = "30"
  evaluation_periods  = "1"
  period              = "120"
  statistic           = "Average"
  dimensions = {
    AutoScalingGroupName = "${aws_autoscaling_group.vivek.name}"
  }

}

resource "aws_cloudwatch_metric_alarm" "vivek_scale_down_alarm" {
  alarm_description   = "Monitors CPU utilization for app"
  alarm_actions       = [aws_autoscaling_policy.vivek_scale_down.arn]
  alarm_name          = "vivek_scale_down"
  comparison_operator = "LessThanOrEqualToThreshold"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  threshold           = "10"
  evaluation_periods  = "1"
  period              = "120"
  statistic           = "Average"

  dimensions = {
    AutoScalingGroupName = "${aws_autoscaling_group.vivek.name}"
  }
}