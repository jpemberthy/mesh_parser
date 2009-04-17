#!/usr/bin/ruby

class MeshParser

attr_accessor :xcor, :ycor, :dp0, :s1, :indexes
attr_reader :f
attr_writer :parsed

def initialize
  @f = File.new(ARGV[0])
  @parsed = File.new("parsed.out", "w+")
  @xcor = []
  @ycor = []
  @dp0 = []
  @s1 = []
  @indexes = []
end


def parse
  puts 'init building matrix'
  build_all
  puts 'init building indexes'
  build_indexes
  puts 'init writing matrixess info'
  @parsed.write("**** VALUES ****\n")
  write_points_info
  puts 'init calculcating triangles'
  @parsed.write("**** TRIANGLES ****\n")
  calculate_triangles
  @parsed.write("\n")
  puts 'finish calculating triangles'
  @f.close
  @parsed.close
end

#builds the indexes array.
def build_indexes
  i = 0
  @xcor.each{|a|
    j = 0
    a.each{|x|
      unless x == "0.000000e+000"
        @indexes << [i,j]
        #puts i.to_s + '  ' + j.to_s
      end
      j = j + 1
    }
    i = i + 1
  }
  @markLow = Array.new(@indexes.size, true) 
  @markUpp = Array.new(@indexes.size, true)
end

def calculate_triangles_sup
  markados_sup = []
  puntos_sup = []
  
  r_i = @indexes.size-1
  
  while(r_i >=0)
    markados_sup[r_i] = Array.new
    puntos_sup[r_i] = Array.new
    
    puntos_sup[r_i] << r_i
    markados_sup[r_i] << r_i
    
    p2 = @indexes[r_i]
    bef_p2 = nil
    
    if @indexes[r_i-1]
      if @indexes[r_i-1][0] == @indexes[r_i][0]
        puntos_sup[r_i] << r_i - 1
        bef_p2 = @indexes[r_i-1]
      end
    end

 
    r_cont = get_last_row(r_i)
    
    if r_cont and bef_p2
      r_k = @indexes[r_cont][0]
      while puntos_sup[r_i].size < 3
        r_current_p = @indexes[r_cont]
        r_bef_p = @indexes[r_cont -1]
        if r_bef_p
        
          d1 = dist(p2, bef_p2, r_current_p)
          d2 = dist(p2, bef_p2, r_bef_p)
        
          if d1 <= d2 and !markados_sup[r_i].include?(r_cont)
            markados_sup[r_i] << r_cont
            puntos_sup[r_i] << r_cont
          end
        else 
          markados_sup[r_i] << r_cont
          puntos_sup[r_i] << r_cont
        end
          break if @indexes[r_cont][0] != r_k
          r_cont = r_cont - 1
      end
      puts "salio de la iteracion No: " + r_i.to_s + 'puntos_inf: ' + puntos_sup[r_i][0].to_s + ' ' + puntos_sup[r_i][1].to_s + ' ' + puntos_sup[r_i][2].to_s
    end    
    r_i = r_i - 1
  end
end

def calculate_triangles
  markados_inf = []
  puntos_inf = [] 
  markados_sup = []
  puntos_sup = []
  
  r_i = @indexes.size-1
   
  for i in 0..@indexes.size-1
    
    markados_inf[i] = Array.new
    puntos_inf[i] = Array.new
    puntos_inf[i] << i
    markados_inf[i] << i
    p1 = @indexes[i]
    next_p1 = nil

    if @indexes[i+1]
      if @indexes[i+1][0] == @indexes[i][0]
        puntos_inf[i] << i+1
        next_p1 = @indexes[i+1]
      end
    end

    cont = get_next_row(i)

    if cont and next_p1
      k = @indexes[cont][0]
      while puntos_inf[i].size < 3
        current_p = @indexes[cont]
        next_p = @indexes[cont+1]
        if next_p

          d1 = dist(p1,next_p1, current_p) 
          d2 = dist(p1,next_p1, next_p)

          if d1 <= d2 and !markados_inf[i].include?(cont)
            markados_inf[i] << cont
            puntos_inf[i] << cont
          end
        else
          markados_inf[i] << cont
          puntos_inf[i] << cont
        end
        break if @indexes[cont][0] != k    
        cont = cont + 1
      end
      @parsed.write("#{puntos_inf[i][0].to_s},#{puntos_inf[i][1].to_s},#{puntos_inf[i][2].to_s},")
      #puts "salio de la iteracion No: " + i.to_s + 'puntos_inf: ' + puntos_inf[i][0].to_s + ' ' + puntos_inf[i][1].to_s + ' ' + puntos_inf[i][2].to_s
    end
    
    #begin SUP
    
    markados_sup[r_i] = Array.new
    puntos_sup[r_i] = Array.new
    puntos_sup[r_i] << r_i
    markados_sup[r_i] << r_i
    
    p2 = @indexes[r_i]
    bef_p2 = nil
    
    if @indexes[r_i-1]
      if @indexes[r_i-1][0] == @indexes[r_i][0]
        puntos_sup[r_i] << r_i - 1
        bef_p2 = @indexes[r_i-1]
      end
    end

 
    r_cont = get_last_row(r_i)
    
    if r_cont and bef_p2
      r_k = @indexes[r_cont][0]
      while puntos_sup[r_i].size < 3
        r_current_p = @indexes[r_cont]
        r_bef_p = @indexes[r_cont -1]
        if r_bef_p
        
          d1 = dist(p2, bef_p2, r_current_p)
          d2 = dist(p2, bef_p2, r_bef_p)
        
          if d1 <= d2 and !markados_sup[r_i].include?(r_cont)
            markados_sup[r_i] << r_cont
            puntos_sup[r_i] << r_cont
          end
        else 
          markados_sup[r_i] << r_cont
          puntos_sup[r_i] << r_cont
        end
          break if @indexes[r_cont][0] != r_k
          r_cont = r_cont - 1
      end
      @parsed.write("#{puntos_sup[r_i][0].to_s},#{puntos_sup[r_i][1].to_s},#{puntos_sup[r_i][2].to_s},")
      #puts "salio de la iteracion No: " + r_i.to_s + 'puntos_inf: ' + puntos_sup[r_i][0].to_s + ' ' + puntos_sup[r_i][1].to_s + ' ' + puntos_sup[r_i][2].to_s
    end    
    r_i = r_i - 1
    
    
  end

  
end


def get_next_row(i)
  r = @indexes[i][0]
  for j in i..@indexes.size-1
    if(@indexes[j][0] != r)
      return j
    end
  end
  false
end

def get_last_row(i)
  r = @indexes[i][0]
  (i-1).downto(0){|t|
    if(@indexes[t][0] != r)
      return t
    end
  }
  false
end

#builds all the matrices.
def build_all
  line = @f.readline
  until matrix_ready?(@xcor, @ycor, @s1, @dp0) 
    if line =~ (/XCOR|YCOR|S1|DP/)
      @parsed.write(line)
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

def dist(a1, a2, a3)
 Math.sqrt( ((a1[0] - a3[0])**2) + ((a1[1] - a3[1])**2) ) + Math.sqrt( ((a2[0] - a3[0])**2) + ((a2[1] - a3[1])**2) )
end

def write_points_info
  i = j = 0
  @xcor.each{|a|
    j = 0 
    a.each{|x|
      unless x == "0.000000e+000"
        s1_str = ''
        dp0_str = ''
        if @dp0.size == @s1.size
          @dp0.size.times {|k|
            dp0_str << @dp0[k][i][j] << ','
            s1_str << @s1[k][i][j] << ','
          }
        else  
          @dp0.size.times {|k|
            dp0_str << @dp0[k][i][j] << ','
          }
          @s1.size.times {|k|
            s1_str << @s1[k][i][j] << ','
          }
        end  
        dp0_str.chop!
        s1_str.chop!
        @parsed.write("#{xcor[i][j]},#{ycor[i][j]},#{s1_str},#{dp0_str}\n")
      end
      j = j + 1
    }
    i = i + 1
  }
end

end
p = MeshParser.new
p.parse