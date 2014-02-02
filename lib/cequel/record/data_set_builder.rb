module Cequel
  module Record
    #
    # This is a utility class to construct a {Metal::DataSet} for a given
    # {RecordSet}.
    #
    # @api private
    #
    class DataSetBuilder
      extend Forwardable

      #
      # Build a data set for the given record set
      #
      # @param (see #initialize)
      # @return [Metal::DataSet] a DataSet exposing the rows for the record set
      #
      def self.build_for(record_set)
        new(record_set).build
      end

      #
      # @param record_set [RecordSet] record set for which to construct data
      #   set
      #
      def initialize(record_set)
        @record_set = record_set
        @data_set = record_set.connection[record_set.target_class.table_name]
      end
      private_class_method :new

      def build
        add_limit
        add_select_columns
        add_where_statement
        add_bounds
        add_order
        data_set
      end

      protected

      attr_accessor :data_set
      attr_reader :record_set
      def_delegators :record_set, :row_limit, :select_columns,
                     :scoped_key_names, :scoped_key_values,
                     :scoped_indexed_column, :lower_bound,
                     :upper_bound, :reversed?, :order_by_column

      private

      def add_limit
        self.data_set = data_set.limit(row_limit) if row_limit
      end

      def add_select_columns
        self.data_set = data_set.select(*select_columns) if select_columns
      end

      def add_where_statement
        if scoped_key_values
          key_conditions = Hash[scoped_key_names.zip(scoped_key_values)]
          self.data_set = data_set.where(key_conditions)
        end
        if scoped_indexed_column
          self.data_set = data_set.where(scoped_indexed_column)
        end
      end

      def add_bounds
        if lower_bound
          self.data_set =
            data_set.where(*lower_bound.to_cql_with_bind_variables)
        end
        if upper_bound
          self.data_set =
            data_set.where(*upper_bound.to_cql_with_bind_variables)
        end
      end

      def add_order
        self.data_set = data_set.order(order_by_column => :desc) if reversed?
      end
    end
  end
end