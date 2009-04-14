#!/usr/bin/ruby
parsed = File.new("parsed.out", "w+")
f = File.open(ARGV[0])

xcor = []
ycor = []
s1 = []
dp0 = []


#builds a simple matriz(no planes) based on the file information
def build_smatrix(m,file)
  2.times {file.readline}
  size = file.readline.split(" ")
  size[0].to_i.times do
    row = file.readline
    m << row.split(" ")
  end
end

#builds and returns and array of matrix, based on the file line/location/information and the plane variable.
def build_dmatrix(file)
  2.times {file.readline}
  size = file.readline.split(" ")
  #this needs to be created dinamically
  m = Array.new(size[2].to_i) { Array.new }
  plane = 0
  #plane.times
  size[2].to_i.times do
    (size[0].to_i/size[2].to_i).times {|k|
      row = file.readline
      m[plane] << row.split(" ")
    }
    plane = plane + 1
  end
  m
end

f.each{|line|
  
  case line
  when /XCOR/
    build_smatrix(xcor, f)
  when /YCOR/
    build_smatrix(ycor,f)
  when /S1/
    s1 = build_dmatrix(f)
  when /DP0/
    dp0 = build_dmatrix(f)
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