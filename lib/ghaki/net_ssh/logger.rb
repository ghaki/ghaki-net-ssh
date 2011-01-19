############################################################################
require 'ghaki/logger/mixin'

############################################################################
module Ghaki
  module NetSSH
    module Logger
      include Ghaki::Logger::Mixin

      ######################################################################
      attr_accessor :should_log_command, :should_log_output

      ######################################################################
      NO_OUTPUT = '** NO OUTPUT **'

      ######################################################################
      def setup_logger opts
        @logger = opts[:logger]
        @should_log_command = opts[:log_ssh_command]
        @should_log_command = true if @should_log_command.nil?
        @should_log_output  = opts[:log_ssh_output]
        @should_log_output  = true if @should_log_output.nil?
      end

      ######################################################################
      # TURN ON/OFF ALL LOGGING
      ######################################################################

      #---------------------------------------------------------------------
      def log_all_on &block
        out = ''
        old_out,old_cmd = @should_log_output,@should_log_command
        @should_log_output = @should_log_command  = true
        if not block.nil?
          begin
            out = block.call
          ensure
            @should_log_output,@should_log_command = old_out,old_cmd
          end
        end
        out
      end

      #---------------------------------------------------------------------
      def log_all_off &block
        out = ''
        old_out,old_cmd = @should_log_output,@should_log_command
        @should_log_output = @should_log_command  = false
        if not block.nil?
          begin
            out = block.call
          ensure
            @should_log_output,@should_log_command = old_out,old_cmd
          end
        end
        out
      end

      ######################################################################
      # TURN COMMAND LOGGIN ON/OFF
      ######################################################################

      #---------------------------------------------------------------------
      def log_command_on &block
        out = ''
        orig,@should_log_command = @should_log_command,true
        if not block.nil?
          begin
            out = block.call
          ensure
            @should_log_command = orig
          end
        end
        out
      end

      #---------------------------------------------------------------------
      def log_command_off &block
        out = ''
        orig,@should_log_command = @should_log_command,false
        if not block.nil?
          begin
            out = block.call
          ensure
            @should_log_command = orig
          end
        end
        out
      end

      ######################################################################
      # TURN OUTPUT LOGGIN ON/OFF
      ######################################################################

      #---------------------------------------------------------------------
      def log_output_on &block
        out = ''
        orig,@should_log_output = @should_log_output,true
        if not block.nil?
          begin
            out = block.call
          ensure
            @should_log_output = orig
          end
        end
        out
      end

      #---------------------------------------------------------------------
      def log_output_off &block
        out = ''
        orig,@should_log_output = @should_log_output,false
        if not block.nil?
          begin
            out = block.call
          ensure
            @should_log_output = orig
          end
        end
        out
      end

      ######################################################################
      # DO THE ACTUAL LOGGING WORK
      ######################################################################

      #---------------------------------------------------------------------
      def log_exec! title, cmd, &block
        log_command! title, cmd
        out = block.call || ''
        return out unless @should_log_output
        if out == ''
          logger.puts( NO_OUTPUT )
        else
          logger.liner
          logger.puts( out )
          logger.liner
        end
        out
      end

      #---------------------------------------------------------------------
      def log_command! title, cmd
        logger.puts "#{title} #{@account.hostname} : #{cmd}" if @should_log_command
      end

    end # class
  end # namespace
end # package
############################################################################
