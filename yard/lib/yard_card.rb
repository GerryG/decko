require "card_loader"

class YardCard < YARD::Handlers::Ruby::Base
    handles method_call(:format)
    handles method_call(:event)
    handles method_call(:view)

    class <<self
        attr_accessor :file, :modloader
        def file= path
            @modloader=nil
            @file=path
        end
    end

    def namespace_from_path
        if YardCard.modloader.nil?
            YardCard.modloader = CardLoader.new YardCard.file
        end
        ns=YardCard.modloader.namespace
        #log.warn "NS: #{YardCard.modloader.namespace}" if !ns.nil?; ns
    end

    def param_details prms
        #log.warn "det:#{prms.class} #{prms[0..2].map(&:inspect)}"
        #prms.inspect
        prms.nil? ? "nil" : prms.map(&:inspect)*", "
        #log.warn "#{unnamed_required_params}, #{prms.unnamed_optional_params}, #{prms.unnamed_end_params}, #{prms.named_params}, #{prms.splat_param}, #{prms.double_splat_param}, #{!prms.block_param.nil?}"
    end

    def check_path
        if YardCard.file != @parser.file
            YardCard.file= @parser.file
            ns=namespace_from_path
            #log.warn "New mod file: #{YardCard.file}#{@parser.namespace.nil? ? "" : " NS: #{ns.inspect}, #{@parser.namespace.inspect}"}"
        #else
        #    log.warn "filter parh #{YardCard.file} #{path}"; nil
        end
        !YardCard.modloader.namespace.nil?
    end

    def process
        if check_path
            #log.warn "Vars:#{instance_variables.map(&:to_s)*", "}"
            if @statement.namespace.nil?
                ns=YardCard.modloader.namespace
                if !ns.nil?
                    newns=@namespace=YARD::CodeObjects::NamespaceObject.new(@statement.namespace, ns)
                    #log.warn "Set ns to #{ns} yns:#{newns}"
                end
            end
            return if @statement.parameters.size < 1

            meth = (@statement.method_name.map(&:to_s)*"#").to_sym
            #log.warn "call Meth:#{meth} NS:#{@statement.namespace} n:#{@statement.parameters.size}"
            rest = @statement.parameters[2..-1]
            name = @statement.parameters[0].jump(:ident)[0].to_s
            #log.warn "Name[#{name}]  R Prms: #{param_details rest} classes [#{rest.nil? ? "nil" : rest.map(&:class)*"; "}]"
            case meth
            when :format
                ns = YardCard.modloader.format_class name
                newns=@namespace=YARD::CodeObjects::NamespaceObject.new(:root, ns)
                #log.warn "Set format ns #{ns} to #{newns.inspect}"
            when :view
            when :event
            end
        end
    rescue => e
        log.warn "Exception #{e} #{e.backtrace[0..5]*", "}"
    end
end

class YardCardClass < YardCard
    handles :class, :sclass
    def process
        if check_path
            #log.warn "Vars:#{instance_variables.map(&:to_s)*", "}"
            #log.warn "ST Vars:#{@statement.instance_variables.map(&:to_s)*", "}"
            #log.warn "Class node #{@statement.class_name
            #    }, #{@statement.superclass
            #    } ST cl:#{@statement.class.name
            #    }, t:#{@statement.type} l:#{@statement.line_range}"
        end
    rescue => e
        log.warn "Exception #{e} #{e.backtrace[0..5]*", "}"
    end
end

class YardCardDef < YardCard
    handles :def
    def process
        if check_path
            #log.warn "Vars:#{instance_variables.map(&:to_s)*", "}"
            #log.warn "ST Vars:#{@statement.instance_variables.map(&:to_s)*", "}"
            #log.warn "Def node CN:#{@statement.method_name*"#"
            #    }, super:#{@statement.class.name
            #    }, parms:#{param_details @statement.parameters[1..-1]
            #    } N:#{@statement.namespace
            #    }, t:#{@statement.type} l:#{@statement.line_range}"
        end
    rescue => e
        log.warn "Exception #{e} #{e.backtrace[0..5]*", "}"
    end
end
