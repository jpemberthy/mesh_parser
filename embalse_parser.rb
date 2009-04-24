#!/opt/local/bin/ruby1.9

class MeshParser

attr_accessor :xcor, :ycor, :dp0, :s1, :indexes, :tolerance, :p_counter
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
  @tolerance = 5 #this value makes smoother the mesh.
  @p_counter = 0
end


def parse
  puts 'building all matrices'
  build_all
  puts 'getting all indexes'
  #build_main_index
  @indexes = 
  puts 'build each index and values'
  build_indexes
  @f.close
  @parsed.close
end

#builds the indexes array.
def build_main_index
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

#builds the sub arrays of indexes
def build_indexes
  while @p_counter < @indexes.size
    (@p_counter + 30000) < @indexes.size ? n = 30000 : n = @indexes.size - @p_counter
    sub_indexes = @indexes[@p_counter, @p_counter + n - 1]
    @parsed.write("**** VALUES ****\n")
    puts 'writting values'
    write_points_info(sub_indexes)
    @parsed.write("**** TRIANGLES ****\n")
    puts 'calculating triangles'
    calculate_triangles(sub_indexes)
    @p_counter += n
  end
end

def write_points_info(sub_index)
  sub_index.size.times{|isi|
    i = sub_index[isi][0]
    j = sub_index[isi][1]
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
    @parsed.write("#{i},#{j},#{xcor[i][j]},#{ycor[i][j]},#{s1_str},#{dp0_str}\n")
  }
end


def calculate_triangles(sub_array)
  markados_inf = []
  puntos_inf = [] 
  markados_sup = []
  puntos_sup = []
  triangles = ''
  
  r_i = sub_array.size-1
  puts 'pos @indexes r_1' + "#{@indexes[r_i]}"
  puts 'pos subarray r_1' + "#{sub_array[r_i]}"
   
  for i in 0..sub_array.size-1
    
    markados_inf[i] = Array.new
    puntos_inf[i] = Array.new
    puntos_inf[i] << i
    markados_inf[i] << i
    p1 = @indexes[i]
    next_p1 = nil

    if sub_array[i+1]
      if sub_array[i+1][0] == sub_array[i][0]
        puntos_inf[i] << i+1
        next_p1 = sub_array[i+1]
      end
    end

    cont = get_next_row(i, sub_array)
    v_point_inf = false
    
    if cont and next_p1
      k = sub_array[cont][0]
      while puntos_inf[i].size < 3
        current_p = sub_array[cont]
        next_p = sub_array[cont+1]
        if next_p

          d1 = dist(p1,next_p1, current_p) 
          d2 = dist(p1,next_p1, next_p)
          
          v_point_inf = true if (d1 <= @tolerance and d2 <= @tolerance)
          
          if d1 <= d2 and !markados_inf[i].include?(cont)
            markados_inf[i] << cont
            puntos_inf[i] << cont
          end
        else
          markados_inf[i] << cont
          puntos_inf[i] << cont
        end
        break if sub_array[cont][0] != k    
        cont = cont + 1
      end
      if v_point_inf
        triangles << "#{puntos_inf[i][0].to_s},#{puntos_inf[i][1].to_s},#{puntos_inf[i][2].to_s},"
        v_point_inf = false
      end
      #puts "salio de la iteracion No: " + i.to_s + 'puntos_inf: ' + puntos_inf[i][0].to_s + ' ' + puntos_inf[i][1].to_s + ' ' + puntos_inf[i][2].to_s
    end
    
    #begin SUP
    
    markados_sup[r_i] = Array.new
    puntos_sup[r_i] = Array.new
    puntos_sup[r_i] << r_i
    markados_sup[r_i] << r_i
    
    p2 = sub_array[r_i]
    bef_p2 = nil
    
    if sub_array[r_i-1]
      if sub_array[r_i-1][0] == sub_array[r_i][0]
        puntos_sup[r_i] << r_i - 1
        bef_p2 = sub_array[r_i-1]
      end
    end

 
    r_cont = get_last_row(r_i, sub_array)
    v_point_sup = false
    
    
    if r_cont and bef_p2
      r_k = sub_array[r_cont][0]
      while puntos_sup[r_i].size < 3
        r_current_p = sub_array[r_cont]
        r_bef_p = sub_array[r_cont -1]
        if r_bef_p
        
          d1 = dist(p2, bef_p2, r_current_p)
          d2 = dist(p2, bef_p2, r_bef_p)
          
          v_point_sup = true if (d1 <= @tolerance and d2 <= @tolerance)
          
          if d1 <= d2 and !markados_sup[r_i].include?(r_cont) 
            markados_sup[r_i] << r_cont
            puntos_sup[r_i] << r_cont
          end
        else 
          markados_sup[r_i] << r_cont
          puntos_sup[r_i] << r_cont
        end
          break if sub_array[r_cont][0] != r_k
          r_cont = r_cont - 1
      end
      
      if v_point_sup
        triangles << "#{puntos_sup[r_i][0].to_s},#{puntos_sup[r_i][1].to_s},#{puntos_sup[r_i][2].to_s},"
        v_point_sup = false
      end
      #puts "salio de la iteracion No: " + r_i.to_s + 'puntos_inf: ' + puntos_sup[r_i][0].to_s + ' ' + puntos_sup[r_i][1].to_s + ' ' + puntos_sup[r_i][2].to_s
    end    
    r_i = r_i - 1
  end
  triangles.chop! << "\n"
  @parsed.write(triangles)
  @parsed.write("**** END TRIANGLES ****\n")
end


def get_next_row(i, array)
  r = array[i][0]
  for j in i..array.size-1
    if(array[j][0] != r)
      return j
    end
  end
  false
end

def get_last_row(i, array)
  r = array[i][0]
  (i-1).downto(0){|t|
    if(array[t][0] != r)
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

end
p = MeshParser.new
p.parse