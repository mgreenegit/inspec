# encoding: utf-8

title 'awspec test'

describe iam_user('my-iam-user') do
  it { should exist }
end
