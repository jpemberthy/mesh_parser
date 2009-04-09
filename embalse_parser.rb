#!/usr/bin/ruby
parsed = File.new("parsed.out", "w+")
f = File.open("c2.out")

xcor = []
ycor = []
s1 = []
dp0 = []

f.each{|line|
  case line
  when /XCOR/
    2.times {f.readline}
    size = f.readline.split(" ")
    size[0].to_i.times do
      row = f.readline
      xcor << row.split(" ")
    end
  when /YCOR/
    2.times {f.readline}
    size = f.readline.split(" ")
    size[0].to_i.times do
      row = f.readline
      ycor << row.split(" ")
    end
  when /S1/
    2.times {f.readline}
    size = f.readline.split(" ")
    #this needs to be created dinamically
    s1 = Array.new(size[2].to_i, Array.new)
    plane = 0
    #plane.times
    size[2].to_i.times do
      (size[0].to_i/size[2].to_i).times do
        row = f.readline
        s1[plane] << row.split(" ")
      end
      plane = plane + 1
    end
  when /DP0/
    2.times {f.readline}
    size = f.readline.split(" ")
    size[0].to_i.times do
      row = f.readline
      dp0 << row.split(" ")
    end
  end
}
f.close

xcor.each{|x| puts x}

parsed.close