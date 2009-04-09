#!/usr/bin/ruby
parsed = File.new("parsed.out", "w+")
f = File.open("c2-3.out")

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

i = j = 0

xcor.each{|a|
  j = 0 
  a.each{|x|
    unless x == "0.000000e+000"
      #puts j.to_s + ' ' + i.to_s
      parsed.write("#{i.to_s},#{j.to_s},#{xcor[i][j]},#{ycor[i][j]}\n")
    end
    j = j + 1
  }
  i = i + 1
}

parsed.close