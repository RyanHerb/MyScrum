module Sequel
  class Dataset
    def igrep(cols, *terms)
      filter(SQL::BooleanExpression.new(:OR, *Array(cols).collect{|c| "(`#{c}` LIKE '#{terms}')".lit}))
    end
  end
  
  module SQL
    class StringExpression
      def self.likeand(l, *ces)
        l, lre, lci = like_element(l)
        lci = (ces.last.is_a?(Hash) ? ces.pop : {})[:case_insensitive] ? true : lci
        ces.flatten!
        ces.map! do |ce|
          r, rre, rci = like_element(ce)
          BooleanExpression.new(LIKE_MAP[[lre||rre, lci||rci]], l, r)
        end
        ces.length == 1 ? ces.at(0) : BooleanExpression.new(:AND, *ces)
      end
    end
    
    module StringMethods
      # Create a BooleanExpression case insensitive pattern match of self
      # with the given patterns.  See StringExpression.like.
      def ilikeand(*ces)
        StringExpression.likeand(self, *(ces << {:case_insensitive=>true}))
      end

      # Create a BooleanExpression case sensitive (if the database supports it) pattern match of self with
      # the given patterns.  See StringExpression.like.
      def likeand(*ces)
        StringExpression.likeand(self, *ces)
      end

      def starts_with(*ces)
        StringExpression.like(self, *(ces.flatten.map{|x| "#{x}%"} << {:case_insensitive=>true}))
      end

      def ends_with(*ces)
        StringExpression.like(self, *(ces.flatten.map{|x| "%#{x}"} << {:case_insensitive=>true}))
      end

      def contains(*ces)
        StringExpression.likeand(self, *(ces.flatten.map{|x| "%#{x}%"} << {:case_insensitive=>true}))
      end

    end
    
  end
  
end
