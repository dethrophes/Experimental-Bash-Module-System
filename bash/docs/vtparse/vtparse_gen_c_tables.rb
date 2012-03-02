
require 'vtparse_tables'

class String
    def pad(len)
        self << (" " * (len - self.length))
    end
end

File.open("vtparse_table.h", "w") { |f|
    f.puts "typedef enum {"
    $states_in_order.each_with_index { |state, i|
        f.puts "   VTPARSE_STATE_#{state.to_s.upcase} = #{i},"
    }
    f.puts "} vtparse_state_t;"
    f.puts
    f.puts "typedef enum {"
    $actions_in_order.each_with_index { |action, i|
        f.puts "   VTPARSE_ACTION_#{action.to_s.upcase} = #{i+1},"
    }
    f.puts "} vtparse_action_t;"
    f.puts
    f.puts "typedef unsigned short state_change_t;"
    f.puts "extern state_change_t STATE_TABLE[#{$states_in_order.length}][256];"
    f.puts "extern vtparse_action_t ENTRY_ACTIONS[#{$states_in_order.length}];"
    f.puts "extern vtparse_action_t EXIT_ACTIONS[#{$states_in_order.length}];"
    f.puts "extern char *ACTION_NAMES[#{$actions_in_order.length+1}];"
    f.puts "extern char *STATE_NAMES[#{$states_in_order.length}];"
    f.puts
}

puts "Wrote vtparse_table.h"

File.open("vtparse_table.c", "w") { |f|
    f.puts
    f.puts '#include "vtparse_table.h"'
    f.puts
    f.puts "char *ACTION_NAMES[] = {"
    f.puts "   \"<no action>\","
    $actions_in_order.each { |action|
        f.puts "   \"#{action.to_s.upcase}\","
    }
    f.puts "};"
    f.puts
    f.puts "char *STATE_NAMES[] = {"
    $states_in_order.each { |state|
        f.puts "   \"#{state.to_s}\","
    }
    f.puts "};"
    f.puts
    f.puts "state_change_t STATE_TABLE[#{$states_in_order.length}][256] = {"
    $states_in_order.each { |state|
        f.puts "  {  /* VTPARSE_STATE_#{state.to_s.upcase} */"
        $state_tables[state].each_with_index { |state_change, i|
            if not state_change
                f.puts "    0,"
            else
                (action,) = state_change.find_all { |s| s.kind_of?(Symbol) }
                (state,)  = state_change.find_all { |s| s.kind_of?(StateTransition) }
                action_str = action ? "VTPARSE_ACTION_#{action.to_s.upcase}" : "0"
                state_str =  state ? "VTPARSE_STATE_#{state.to_state.to_s}" : "0"
                f.puts "/*#{i.to_s.pad(3)} 0x#{i.to_s(16).pad(3)}#{i.chr.pad(3)}*/  #{action_str.pad(33)} | (#{state_str.pad(33)} << 4),"
            end
        }
        f.puts "  },"
    }

    f.puts "};"
    f.puts
    f.puts "vtparse_action_t ENTRY_ACTIONS[] = {"
    $states_in_order.each { |state|
        actions = $states[state]
        if actions[:on_entry]
            f.puts "   VTPARSE_ACTION_#{actions[:on_entry].to_s.upcase}, /* #{state} */"
        else
            f.puts "   0  /* none for #{state} */,"
        end
    }
    f.puts "};"
    f.puts
    f.puts "vtparse_action_t EXIT_ACTIONS[] = {"
    $states_in_order.each { |state|
        actions = $states[state]
        if actions[:on_exit]
            f.puts "   VTPARSE_ACTION_#{actions[:on_exit].to_s.upcase}, /* #{state} */"
        else
            f.puts "   0  /* none for #{state} */,"
        end
    }
    f.puts "};"
    f.puts
}

puts "Wrote vtparse_table.c"

File.open("vtparse_table.sh", "w") { |f|
    f.puts
    f.puts
    $actions_in_order.each_with_index { |action, i|
        f.puts "declare -gri VTPARSE_ACTION_#{action.to_s.upcase}=\"#{(i+1)}\""
    }
    f.puts
    f.puts "declare -gra VTPARSE_ACTION_NAMES=("
    f.puts "   [0 ]=\"<no action>\""
    $actions_in_order.each_with_index { |action, i|
        f.puts "   [${VTPARSE_ACTION_#{action.to_s.upcase}}]=\"#{action.to_s.upcase}\""
    }
    f.puts ")"
    $states_in_order.each_with_index { |state, i|
        f.puts "declare -gri VTPARSE_STATE_#{state.to_s.upcase}=\"#{i}\""
    }
    f.puts
    f.puts "declare -gra VTPARSE_STATE_NAMES=("
    $states_in_order.each_with_index { |state, i|
        f.puts "   [${VTPARSE_STATE_#{state.to_s.upcase}}]=\"#{state}\""
    }
    f.puts ")"

    f.puts "declare -gra VTPARSE_STATE_TABLE=("
    $states_in_order.each_with_index { |state, p|
        f.print "  [${VTPARSE_STATE_#{state.to_s.upcase}}]=\""
        $state_tables[state].each_with_index { |state_change, i|
            if not state_change
                f.print "00"
            else
                (action,) = state_change.find_all { |s| s.kind_of?(Symbol) }
                (state,)  = state_change.find_all { |s| s.kind_of?(StateTransition) }
                action_str = action ? "#{($actions_in_order.index(action)+1).to_s(36)}" : "0"
                state_str =  state ? "#{$states_in_order.index(state.to_state).to_s(36)}" : "0"

                f.print "#{action_str}#{state_str}"
            end
        }
				f.puts "\""
    }

    f.puts ")"
    f.puts ""

    f.print "declare -gr VTPARSE_BASE=\""
		for i in 0..35
			f.print "#{i.to_s(36)}"
		end
    f.puts "\""

    f.print "declare -gr VTPARSE_ENTRY_ACTIONS=\""
    $states_in_order.each { |state|
        actions = $states[state]
        if actions[:on_entry]
            f.print "#{($actions_in_order.index(actions[:on_entry][0])+1).to_s(36)}"
        else
            f.print "0"
        end
    }
    f.puts "\""
    f.puts
    f.print "declare -gr VTPARSE_EXIT_ACTIONS=\""
    $states_in_order.each { |state|
        actions = $states[state]
        if actions[:on_exit]
            f.print "#{($actions_in_order.index(actions[:on_exit][0])+1).to_s(36)}"
        else
            f.print "0"
        end
    }
    f.puts "\""
    f.puts
}

puts "Wrote vtparse_table.sh"

