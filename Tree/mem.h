namespace tensorflow {

Status ValidateMemoryTypes(DeviceType device_type, const Graph* g);
Status EnsureMemoryTypes(DeviceType device_type, const string& device_name,
   
                         
          Graph* g);


Status MemoryTypeForOutput(DeviceType device_type, const Graph* g,
                          
                           
            const Node* n, int index, MemoryType* memory_type);

}  

#endif 
