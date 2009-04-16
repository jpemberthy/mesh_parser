#!/usr/bin/ruby

class MeshParser

attr_accessor :f, :xcor, :ycor, :dp0, :s1, :parsed

def initialize
  @f = File.new(ARGV[0])
  @parsed = File.new("parsed.out", "w+")
  @xcor = []
  @ycor = []
  @dp0 = []
  @s1 = []
end


def parse
  ind_1_inf = ind_2_inf = ind_1_sup = ind_2_sup  = -1
  markLoww = []
  markUpp = []
  build_all
  #call functions
  @f.close
  @parsed.close
  
end


#builds all the matrix
def build_all
  line = @f.readline

  until matrix_ready?(@xcor, @ycor, @s1, @dp0) 

    if line =~ (/XCOR|YCOR|S1|DP/)
      if line =~ /XCOR/
        build_smatrix(@xcor)
      elsif line =~ /YCOR/
        build_smatrix(@ycor)
      elsif line =~ /S1/
        @s1 = build_dmatrix
      elsif line =~ /DP/
        @dp0 = build_dmatrix
      end
    end
    line = @f.readline unless @f.eof?
  end

end

#builds a simple matriz(no planes) based on the file information
def build_smatrix(m)
  2.times {@f.readline}
  size = @f.readline.split(" ")
  size[0].to_i.times do
    row = @f.readline
    m << row.split(" ")
  end
end

#builds and returns and array of matrix, based on the file line/location/information and the plane variable.
def build_dmatrix
  2.times {@f.readline}
  size = @f.readline.split(" ")
  #this needs to be created dinamically
  m = Array.new(size[2].to_i) { Array.new }
  plane = 0
  #plane.times
  size[2].to_i.times do
    (size[0].to_i/size[2].to_i).times {|k|
      row = @f.readline
      m[plane] << row.split(" ")
    }
    plane = plane + 1
  end
  m
end

#true if all matrix have been already parsed.
def matrix_ready?(x, y, s1, dp0)
  return true if (x.size > 0) and (y.size > 0) and (s1.size > 0) and (dp0.size > 0)
  false
end

def distance(a1, a2)
  Math.sqrt( ((a1[0] - a2[0])**2) + ((a1[1] - a2[1])**2) )
end

def get_triangle_points(posInf, posSup)
  markLow[posInf] = false
  markUpp[posSup] = false
  
  min_1_inf =  min_2_inf = min_1_sup = min_2_sup = 999
  ind_1_inf = ind_2_inf = ind_1_sup = ind_2_sup  = -1
  
  distInf = indexes[posInf]
  distSup = indexes[posSup]
  
  for i in 0..indexes.size
    ct = indexes.size - 1 - i
    
    if (min_1_inf > distance(distInf, indexes[i])) and markLow[i]
      min_1_inf = distance(distInf, indexes[i])
      ind_1_inf = i
    elsif (min_2_inf > distance(distInf, indexes[i])) and markLow[i] and i != ind_1_inf
      min_2_inf = distance(distInf, indexes[i])
      ind_2_inf = i
    end
    
    if (min_1_sup > distance(distSup, indexes[ct])) and markUpp[ct]
      min_1_sup = distance(distSup, indexes[ct])
      ind_1_sup = ct
    elsif (min_2_sup > distance(distSup, indexes[ct])) and markUpp[ct] and ct != ind_1_sup
      min_2_sup = distance(distSup, indexes[ct])
      ind_2_sup = ct
    end
    
  end

end

=begin
line = f.readline

until matrix_ready?(xcor, ycor, s1, dp0) 
  
  if line =~ (/XCOR|YCOR|S1|DP/)
    if line =~ /XCOR/
      puts 'init xcor'
      build_smatrix(xcor, f)
      puts 'finish xcor'
    elsif line =~ /YCOR/
            puts 'init ycor'
      build_smatrix(ycor,f)
            puts 'finish ycor'
    elsif line =~ /S1/
            puts 'init s1'
      s1 = build_dmatrix(f)
      puts 'finish s1'
    elsif line =~ /DP/
      puts 'init dp'
      dp0 = build_dmatrix(f)
      puts 'finish dp'
    end
  end
  
  line = f.readline unless f.eof?
end

=begin
i = 0
xcor.each{|a|
  j = 0
  a.each{|x|
    unless x == "0.000000e+000"
      indexes << [i,j]
    end
    j = j + 1
  }
  i = i + 1
}

markLow = Array.new(indexes.size, true) 
markUpp = Array.new(indexes.size, true)

puts indexes[0][1]

#generates triangle points

=begin
for i in 0..indexes.size
  get_triangle_points(i, indexes.size - 1 - i, markLow, markUpp, indexes)
  
  if ind_1_inf != -1 and ind_2_inf != -1
    puts i.to_s + ' ' + ind_1_inf.to_s + ' ' + ind_2_inf.to_s
  end
  
  if ind_1_sup != -1 and ind_2_sup != -1
    puts (indexes.size - 1 - i).to_s + ' ' + ind_1_inf.to_s + ' ' + ind_2_inf.to_s
  end
  
end

=begin
i = j = 0

xcor.each{|a|
  j = 0 
  a.each{|x|
    unless x == "0.000000e+000"
      s1_str = ''
      dp0_str = ''
      if dp0.size == s1.size
        dp0.size.times {|k|
          dp0_str << dp0[k][i][j] << ','
          s1_str << s1[k][i][j] << ','
        }
      else  
        dp0.size.times {|k|
          dp0_str << dp0[k][i][j] << ','
        }
        s1.size.times {|k|
          s1_str << s1[k][i][j] << ','
        }
      end  
      dp0_str.chop!
      s1_str.chop!
      parsed.write("#{i.to_s},#{j.to_s},#{xcor[i][j]},#{ycor[i][j]},#{s1_str},#{dp0_str}\n")
    end
    j = j + 1
  }
  i = i + 1
}
=end
end

p = MeshParser.new
p.parse